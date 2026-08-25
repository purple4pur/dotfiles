#!/usr/bin/env python3
"""Extract reusable performance evidence from Codex rollout JSONL logs.

Select root by --log, --session, or CODEX_THREAD_ID. Include linked subagents
by default. Measure only task_started/task_complete pairs, which excludes the
currently running report turn and copied parent history in forked rollouts.
Read-only: prints digest; never edits logs or reports.
"""
import argparse
import glob
import json
import os
import re
import sys
from collections import Counter, defaultdict
from datetime import datetime


TOKEN_KEYS = (
    'input_tokens',
    'cached_input_tokens',
    'output_tokens',
    'reasoning_output_tokens',
    'total_tokens',
)
CLI_PATTERNS = (
    ('sed', r'\bsed\b'),
    ('git', r'\bgit\b'),
    ('rg', r'\brg\b'),
    ('python3', r'\bpython3\b'),
    ('quick_validate.py', r'quick_validate\.py'),
    ('find', r'\bfind\b'),
)


def fail(message):
    print('error:', message, file=sys.stderr)
    raise SystemExit(1)


def ts(value):
    return datetime.fromisoformat(value.replace('Z', '+00:00'))


def read_jsonl(path):
    try:
        with open(path) as stream:
            return [json.loads(line) for line in stream if line.strip()]
    except (OSError, ValueError) as exc:
        fail('%s: %s' % (path, exc))


def session_meta(events):
    return next((e.get('payload', {}) for e in events
                 if e.get('type') == 'session_meta'), {})


def codex_roots():
    roots = [os.path.join(os.getcwd(), '.codex', 'sessions')]
    home = os.path.expanduser('~/.codex/sessions')
    if home not in roots:
        roots.append(home)
    return roots


def find_rollout(session_id=None, explicit_log=None):
    if explicit_log:
        path = os.path.abspath(os.path.expanduser(explicit_log))
        if not os.path.isfile(path):
            fail('Codex rollout not found: %s' % path)
        events = read_jsonl(path)
        if not session_meta(events):
            fail('not a Codex rollout JSONL: %s' % path)
        return path

    sid = session_id or os.environ.get('CODEX_THREAD_ID')
    if not sid:
        fail('no Codex session id: pass --session <id> or --log <rollout.jsonl>; '
             'automatic detection needs CODEX_THREAD_ID')

    hits = []
    for root in codex_roots():
        hits.extend(glob.glob(os.path.join(root, '**', 'rollout-*%s.jsonl' % sid),
                              recursive=True))
    hits = sorted(set(os.path.abspath(path) for path in hits))
    if not hits:
        fail('no Codex rollout found for session %s' % sid)
    if len(hits) > 1:
        fail('ambiguous Codex session %s; pass --log. Candidates: %s' %
             (sid, ', '.join(hits)))
    return hits[0]


def completed_spans(events):
    starts = {}
    spans = []
    for event in events:
        payload = event.get('payload', {})
        if event.get('type') != 'event_msg':
            continue
        if payload.get('type') == 'task_started':
            starts[payload.get('turn_id')] = event
        elif payload.get('type') == 'task_complete':
            start = starts.get(payload.get('turn_id'))
            if not start:
                continue
            start_time = ts(start['timestamp'])
            end_time = ts(event['timestamp'])
            duration = payload.get('duration_ms')
            spans.append({
                'turn_id': payload.get('turn_id'),
                'start': start_time,
                'end': end_time,
                'duration_s': (duration / 1000.0 if duration is not None
                               else (end_time - start_time).total_seconds()),
            })
    return sorted(spans, key=lambda span: span['start'])


def containing_span(moment, spans):
    return next((span for span in spans
                 if span['start'] <= moment <= span['end']), None)


def token_records(events, spans, contexts):
    records = []
    duplicates = 0
    excluded = 0
    previous_total = None
    for event in events:
        payload = event.get('payload', {})
        if event.get('type') != 'event_msg' or payload.get('type') != 'token_count':
            continue
        info = payload.get('info') or {}
        total = info.get('total_token_usage') or {}
        last = info.get('last_token_usage') or {}
        if not last or 'total_tokens' not in total:
            continue
        moment = ts(event['timestamp'])
        duplicate = previous_total == total.get('total_tokens')
        previous_total = total.get('total_tokens')
        span = containing_span(moment, spans)
        if not span:
            excluded += 1
            continue
        if duplicate:
            duplicates += 1
            continue
        context = contexts.get(span['turn_id'], {})
        records.append({
            'time': moment,
            'usage': {key: int(last.get(key, 0)) for key in TOKEN_KEYS},
            'cumulative': {key: int(total.get(key, 0)) for key in TOKEN_KEYS},
            'turn_id': span['turn_id'],
            'model': context.get('model', 'unknown'),
            'effort': context.get('effort', 'unknown'),
        })
    return records, duplicates, excluded


def tool_records(events, spans):
    calls = {}
    for event in events:
        payload = event.get('payload', {})
        kind = payload.get('type')
        if event.get('type') != 'response_item':
            continue
        if kind in ('function_call', 'custom_tool_call'):
            calls[payload.get('call_id')] = {
                'name': payload.get('name', 'unknown'),
                'start': ts(event['timestamp']),
                'input': payload.get('input') or payload.get('arguments') or '',
            }
        elif kind in ('function_call_output', 'custom_tool_call_output'):
            call = calls.get(payload.get('call_id'))
            if call and 'end' not in call:
                call['end'] = ts(event['timestamp'])

    matched = []
    unmatched = 0
    for call in calls.values():
        span = containing_span(call['start'], spans)
        if not span:
            continue
        if 'end' not in call or call['end'] > span['end']:
            unmatched += 1
            continue
        call['duration_s'] = (call['end'] - call['start']).total_seconds()
        call['turn_id'] = span['turn_id']
        matched.append(call)
    return matched, unmatched


def user_records(events, spans):
    users = []
    for event in events:
        payload = event.get('payload', {})
        if event.get('type') != 'event_msg' or payload.get('type') != 'user_message':
            continue
        moment = ts(event['timestamp'])
        span = containing_span(moment, spans)
        if span:
            text = (payload.get('message') or '').replace('\n', ' ').replace('\r', ' ')
            users.append({'time': moment, 'turn_id': span['turn_id'], 'text': text[:100]})
    return users


def subagent_links(events, spans):
    links = []
    for event in events:
        payload = event.get('payload', {})
        if (event.get('type') == 'event_msg'
                and payload.get('type') == 'sub_agent_activity'
                and payload.get('kind') == 'started'
                and containing_span(ts(event['timestamp']), spans)):
            links.append((payload.get('agent_thread_id'), payload.get('agent_path')))
    return links


def reconciliation(events, spans, records):
    all_tokens = []
    for event in events:
        payload = event.get('payload', {})
        if (event.get('type') == 'event_msg'
                and payload.get('type') == 'token_count'
                and payload.get('info')):
            all_tokens.append((ts(event['timestamp']), payload['info']))

    checks = []
    for span in spans:
        before = [info['total_token_usage'] for moment, info in all_tokens
                  if moment < span['start']]
        inside = [info['total_token_usage'] for moment, info in all_tokens
                  if span['start'] <= moment <= span['end']]
        baseline = before[-1] if before else {key: 0 for key in TOKEN_KEYS}
        final = inside[-1] if inside else baseline
        measured = [record for record in records if record['turn_id'] == span['turn_id']]
        summed = {key: sum(record['usage'][key] for record in measured)
                  for key in TOKEN_KEYS}
        delta = {key: int(final.get(key, 0)) - int(baseline.get(key, 0))
                 for key in TOKEN_KEYS}
        checks.append({
            'turn_id': span['turn_id'],
            'baseline_total': int(baseline.get('total_tokens', 0)),
            'final_total': int(final.get('total_tokens', 0)),
            'delta': delta,
            'sum_last': summed,
            'pass': delta == summed,
        })
    return checks


def parse_rollout(path, label=None):
    events = read_jsonl(path)
    meta = session_meta(events)
    sid = meta.get('id') or meta.get('session_id')
    if not sid:
        fail('missing session id in %s' % path)
    spans = completed_spans(events)
    contexts = {e.get('payload', {}).get('turn_id'): e.get('payload', {})
                for e in events if e.get('type') == 'turn_context'}
    tokens, duplicates, excluded = token_records(events, spans, contexts)
    tools, unmatched = tool_records(events, spans)
    return {
        'id': sid,
        'label': label or 'root',
        'path': path,
        'provider': meta.get('model_provider', 'unknown'),
        'events': events,
        'spans': spans,
        'tokens': tokens,
        'tools': tools,
        'users': user_records(events, spans),
        'links': subagent_links(events, spans),
        'duplicates': duplicates,
        'excluded': excluded,
        'unmatched_tools': unmatched,
        'checks': reconciliation(events, spans, tokens),
    }


def sum_tokens(records):
    return {key: sum(record['usage'][key] for record in records)
            for key in TOKEN_KEYS}


def union_seconds(intervals):
    intervals = sorted(intervals)
    if not intervals:
        return 0.0
    start, end = intervals[0]
    total = 0.0
    for next_start, next_end in intervals[1:]:
        if next_start <= end:
            end = max(end, next_end)
        else:
            total += (end - start).total_seconds()
            start, end = next_start, next_end
    return total + (end - start).total_seconds()


def clip_intervals(intervals, spans):
    clipped = []
    for start, end in intervals:
        for span in spans:
            if start < span['end'] and end > span['start']:
                clipped.append((max(start, span['start']), min(end, span['end'])))
    return clipped


def load_tree(root_path, include_subagents=True):
    root = parse_rollout(root_path)
    agents = [root]
    missing = []
    if not include_subagents:
        return agents, missing

    queue = list(root['links'])
    seen = {root['id']}
    while queue:
        sid, label = queue.pop(0)
        if not sid or sid in seen:
            continue
        seen.add(sid)
        try:
            path = find_rollout(session_id=sid)
        except SystemExit:
            missing.append((sid, label))
            continue
        agent = parse_rollout(path, label=label)
        agents.append(agent)
        queue.extend(agent['links'])
    return agents, missing


def print_digest(agents, missing):
    root = agents[0]
    spans = root['spans']
    records = [record for agent in agents for record in agent['tokens']]
    tools = [tool for agent in agents for tool in agent['tools']]
    totals = sum_tokens(records)
    active = sum(span['duration_s'] for span in spans)
    agent_active = sum(span['duration_s'] for agent in agents for span in agent['spans'])
    if spans:
        first, end = spans[0]['start'], spans[-1]['end']
        elapsed = (end - first).total_seconds()
    else:
        first = end = None
        elapsed = 0.0

    tool_intervals = [(tool['start'], tool['end']) for tool in tools]
    tool_union = union_seconds(clip_intervals(tool_intervals, spans))
    tool_sum = sum(tool['duration_s'] for tool in tools)

    print('== session ==')
    print('agent: Codex')
    print('id:', root['id'])
    print('root:', root['path'])
    print('linked subagents:', len(agents) - 1)
    for agent in agents[1:]:
        print(' ', agent['label'], agent['id'], agent['path'])
    if missing:
        print('missing linked rollouts:', ', '.join('%s %s' % item for item in missing))
    print('completed turns:', len(spans), 'incomplete/unpaired turns excluded')
    print('first:', first.isoformat() if first else 'none')
    print('e2e-end:', end.isoformat() if end else 'none')
    print('end-to-end: %.3fs  active: %.3fs  idle: %.3fs' %
          (elapsed, active, elapsed - active))
    print('aggregate agent-active: %.3fs' % agent_active)

    print('\n== user turns ==')
    for user in root['users']:
        print(' ', user['time'].isoformat(), '|', user['text'])
    if not root['users']:
        print('  none completed')

    print('\n== measured totals (raw) ==')
    print('  input: %d  cached: %d  output: %d  reasoning: %d  total: %d' %
          (totals['input_tokens'], totals['cached_input_tokens'],
           totals['output_tokens'], totals['reasoning_output_tokens'],
           totals['total_tokens']))
    print('  api usages: %d  matched tools: %d  unmatched tools: %d' %
          (len(records), len(tools), sum(agent['unmatched_tools'] for agent in agents)))
    print('  tool wall union: %.3fs  additive agent tool wall: %.3fs' %
          (tool_union, tool_sum))
    print('  excluded token events: %d  unchanged duplicates: %d' %
          (sum(agent['excluded'] for agent in agents),
           sum(agent['duplicates'] for agent in agents)))

    print('\n== per-turn ==')
    print('  turn | span | tool_union | api_calls | input | cached | output | reasoning | tool_calls')
    for number, span in enumerate(spans, 1):
        turn_tokens = [record for record in records
                       if span['start'] <= record['time'] <= span['end']]
        turn_tools = [tool for tool in tools
                      if span['start'] <= tool['start'] <= span['end']]
        sums = sum_tokens(turn_tokens)
        union = union_seconds(clip_intervals(
            [(tool['start'], tool['end']) for tool in turn_tools], [span]))
        print('  %d | %.3fs | %.3fs | %d | %d | %d | %d | %d | %d' %
              (number, span['duration_s'], union, len(turn_tokens),
               sums['input_tokens'], sums['cached_input_tokens'],
               sums['output_tokens'], sums['reasoning_output_tokens'],
               len(turn_tools)))

    print('\n== agents ==')
    print('  agent | active | api_calls | tool_calls | tool_sum | input | cached | output | reasoning | model/effort')
    for agent in agents:
        sums = sum_tokens(agent['tokens'])
        models = Counter((record['model'], record['effort']) for record in agent['tokens'])
        model_text = ', '.join('%s/%s:%d' % (model, effort, count)
                               for (model, effort), count in sorted(models.items())) or 'unknown'
        print('  %s | %.3fs | %d | %d | %.3fs | %d | %d | %d | %d | %s' %
              (agent['label'], sum(span['duration_s'] for span in agent['spans']),
               len(agent['tokens']), len(agent['tools']),
               sum(tool['duration_s'] for tool in agent['tools']),
               sums['input_tokens'], sums['cached_input_tokens'],
               sums['output_tokens'], sums['reasoning_output_tokens'], model_text))

    per_tool = defaultdict(lambda: [0, 0.0])
    for tool in tools:
        per_tool[tool['name']][0] += 1
        per_tool[tool['name']][1] += tool['duration_s']
    print('\n== tool calls ==')
    for name, (count, seconds) in sorted(per_tool.items(), key=lambda item: -item[1][1]):
        print('  %-24s calls=%d sum=%.3fs' % (name, count, seconds))

    wrappers = defaultdict(lambda: [0, 0.0])
    cli = defaultdict(lambda: [0, 0.0])
    for tool in tools:
        if tool['name'] != 'exec':
            continue
        text = str(tool['input'])
        for operation in ('exec_command', 'apply_patch', 'update_plan', 'view_image'):
            if 'tools.%s' % operation in text:
                wrappers[operation][0] += 1
                wrappers[operation][1] += tool['duration_s']
        for name, pattern in CLI_PATTERNS:
            if re.search(pattern, text):
                cli[name][0] += 1
                cli[name][1] += tool['duration_s']
    print('\n== operations inside exec wrapper (overlap) ==')
    for name, (count, seconds) in sorted(wrappers.items(), key=lambda item: -item[1][1]):
        print('  %-24s wrappers=%d wall=%.3fs' % (name, count, seconds))
    print('\n== CLI batches inside exec wrapper (overlap) ==')
    for name, (count, seconds) in sorted(cli.items(), key=lambda item: -item[1][1]):
        print('  %-24s batches=%d wall=%.3fs' % (name, count, seconds))

    print('\n== reconciliation ==')
    failed = False
    for agent in agents:
        for check in agent['checks']:
            failed = failed or not check['pass']
            print('  %s %s baseline=%d final=%d sum_last=%d %s' %
                  (agent['label'], check['turn_id'], check['baseline_total'],
                   check['final_total'], check['sum_last']['total_tokens'],
                   'PASS' if check['pass'] else 'FAIL'))
    if failed:
        fail('token reconciliation failed')


def main():
    parser = argparse.ArgumentParser(description='Codex session performance evidence digest')
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--session', help='root Codex thread/session id')
    group.add_argument('--log', help='explicit root rollout JSONL')
    parser.add_argument('--no-subagents', action='store_true',
                        help='measure only the root rollout')
    args = parser.parse_args()

    root_path = find_rollout(args.session, args.log)
    agents, missing = load_tree(root_path, include_subagents=not args.no_subagents)
    print_digest(agents, missing)


if __name__ == '__main__':
    main()
