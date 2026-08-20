#!/usr/bin/env python3
"""Extract performance-evidence digest from agent session logs.

Qwen Code (primary):
  chat log            ~/.qwen/projects/*/chats/<uuid>.jsonl
  per-response tokens ~/.qwen/usage/token-usage-*.jsonl
Session id from --session, else skill args path .qwen/tmp/s-<uuid>/, else
newest chat log. Default excludes current report turn (records at/after last
user message). Read-only — never writes logs.

Prints a digest: turn boundaries, active spans, per-turn + total token sums,
tool call/result pairs with durations, per-tool aggregates, union tool wall.
Report build (scope, phases, findings) stays model work. If the script fails
or the agent is unknown, fall back to manual evidence collection (skill §2).
"""
import argparse
import glob
import json
import os
import re
import sys
from collections import Counter
from datetime import datetime


def ts(s):
    return datetime.fromisoformat(s.replace('Z', '+00:00'))


def find_session_id(explicit):
    if explicit:
        return explicit
    hits = glob.glob(os.path.join(os.getcwd(), '.qwen', 'tmp', 's-*', 'qwen-skill-args-*.txt'))
    if hits:
        m = re.search(r'/s-([0-9a-f-]{36})/', max(hits, key=os.path.getmtime))
        if m:
            return m.group(1)
    chats = glob.glob(os.path.expanduser('~/.qwen/projects/*/chats/*.jsonl'))
    if chats:
        return os.path.basename(max(chats, key=os.path.getmtime))[:-6]
    return None


def load_chat(path):
    events = [json.loads(l) for l in open(path)]
    users, calls, model_times = [], {}, []
    for e in events:
        t = ts(e['timestamp'])
        if e['type'] == 'user':
            txt = ''.join(p.get('text', '') for p in (e.get('message') or {}).get('parts', [])
                          if isinstance(p, dict))
            users.append({'t': t, 'text': txt[:80].replace('\n', ' ')})
        elif e['type'] == 'assistant':
            model_times.append(t)
            for p in e['message']['parts']:
                if 'functionCall' in p:
                    calls[p['functionCall']['id']] = {'name': p['functionCall']['name'], 't0': t}
        elif e['type'] == 'tool_result':
            model_times.append(t)
            fr = (e['message']['parts'][0] or {}).get('functionResponse', {})
            c = calls.get(fr.get('id'))
            if c and 't1' not in c:
                c['t1'] = t
                c['status'] = e.get('toolCallResult', {}).get('status')
    return events, users, calls, model_times


def usage_records(sid):
    recs = []
    for f in glob.glob(os.path.expanduser('~/.qwen/usage/token-usage-*.jsonl')):
        for line in open(f):
            u = json.loads(line)
            if u.get('sessionId') == sid:
                recs.append(u)
    return sorted(recs, key=lambda u: u['timestamp'])


def main():
    ap = argparse.ArgumentParser(description='session performance evidence digest')
    ap.add_argument('--session', help='session id (auto-detect if omitted)')
    a = ap.parse_args()

    sid = find_session_id(a.session)
    chat = None
    if sid:
        hits = glob.glob(os.path.expanduser('~/.qwen/projects/*/chats/%s.jsonl' % sid))
        if hits:
            chat = hits[0]
    if not chat:
        print('no Qwen Code session logs found (try --session <id>, or run from workspace '
              'with a .qwen/tmp/s-* args file)', file=sys.stderr)
        sys.exit(1)

    events, users, calls, model_times = load_chat(chat)
    recs = usage_records(sid)

    first = ts(events[0]['timestamp'])
    user_times = [u['t'] for u in users]
    last_event = max(model_times + user_times)
    boundary = None if len(users) < 2 else user_times[-1]

    def before(t):
        return True if boundary is None else t < boundary

    m_users = [u for u in users if before(u['t'])]
    m_calls = [c for c in calls.values() if before(c['t0']) and 't1' in c]
    m_recs = [u for u in recs if before(ts(u['timestamp']))]

    spans = []
    for u in m_users:
        next_user = next((ut for ut in user_times if ut > u['t']), None)
        lim = next_user if next_user else (boundary or last_event)
        ends = [t for t in model_times if t < lim]
        spans.append((u['t'], max(ends) if ends else lim))

    active = sum((e - s).total_seconds() for s, e in spans)
    e2e = ((boundary or last_event) - first).total_seconds()

    per_turn = []
    for i, (s, e) in enumerate(spans):
        nxt = spans[i + 1][0] if i + 1 < len(spans) else (boundary or last_event)
        rec = [r for r in m_recs if s <= ts(r['timestamp']) < nxt]
        tcalls = [c for c in m_calls if s <= c['t0'] < nxt]
        csum = lambda k: sum(r.get(k, 0) for r in rec)
        per_turn.append({
            'turn': i + 1, 'start': s.isoformat(), 'end': e.isoformat(),
            'span': (e - s).total_seconds(),
            'tool_wall_sum': sum((c['t1'] - c['t0']).total_seconds() for c in tcalls),
            'api_calls': len(rec), 'tool_calls': len(tcalls),
            'input': csum('inputTokens'), 'cached': csum('cachedTokens'),
            'output': csum('outputTokens'), 'reasoning': csum('thoughtsTokens'),
            'api_ms': csum('apiDurationMs'),
        })

    tot = lambda k: sum(r.get(k, 0) for r in m_recs)

    per_tool = Counter()
    per_tool_calls = Counter()
    intervals = sorted((c['t0'], c['t1']) for c in m_calls)
    union = 0.0
    if intervals:
        cs, ce = intervals[0]
        for s, e in intervals[1:]:
            if s <= ce:
                ce = max(ce, e)
            else:
                union += (ce - cs).total_seconds()
                cs, ce = s, e
        union += (ce - cs).total_seconds()
    for c in m_calls:
        per_tool[c['name']] += (c['t1'] - c['t0']).total_seconds()
        per_tool_calls[c['name']] += 1
    errs = Counter(c['name'] for c in m_calls if c.get('status') == 'error')

    print('== session ==')
    print('id:', sid)
    print('chat:', chat)
    print('usage records: %d total in file(s), %d measured' % (len(recs), len(m_recs)))
    print('models:', dict(Counter(r['model'] for r in m_recs)))
    print('first:', first.isoformat())
    print('e2e-end:', (boundary or last_event).isoformat())
    print('end-to-end: %.3fs  active: %.3fs  idle: %.3fs' % (e2e, active, e2e - active))
    print()
    print('== user turns ==')
    for u in users:
        mark = '' if before(u['t']) else '  [current turn - excluded]'
        print(' ', u['t'].isoformat(), '|', u['text'], mark)
    print()
    print('== measured totals (raw) ==')
    print('  input: %d  cached: %d  output: %d  reasoning: %d  total: %d  apiMs: %d' % (
        tot('inputTokens'), tot('cachedTokens'), tot('outputTokens'), tot('thoughtsTokens'),
        tot('inputTokens') + tot('outputTokens'), tot('apiDurationMs')))
    print()
    print('== per-turn ==')
    print('  turn | span | tool_wall_sum | api_calls | input | cached | output | reasoning | api_ms | tool_calls')
    for pt in per_turn:
        print('  %d | %.3fs | %.3fs | %d | %d | %d | %d | %d | %d | %d' % (
            pt['turn'], pt['span'], pt['tool_wall_sum'], pt['api_calls'], pt['input'],
            pt['cached'], pt['output'], pt['reasoning'], pt['api_ms'], pt['tool_calls']))
    print()
    print('== tool calls (%d matched) ==' % len(m_calls))
    for name in sorted(per_tool, key=lambda n: -per_tool[n]):
        print('  %-24s calls=%d sum=%.3fs' % (name, per_tool_calls[name], per_tool[name]))
    print('  tool wall union: %.3fs' % union)
    print('  errors:', dict(errs) if errs else 'none')


if __name__ == '__main__':
    main()
