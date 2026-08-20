---
name: session-performance-report
description: "Measure and report AI session performance from local session logs (auto-detects agent: Qwen Code chats/*.jsonl + usage/token-usage-*.jsonl, or Codex rollout-*.jsonl): end-to-end and active wall time, derived API/agent time, tool time, input/cached/output/reasoning tokens, phase and skill attribution, tool usage, and model usage. Use when users ask for session statistics, debug performance, token-cost analysis, elapsed-time analysis, tool/model breakdowns, bottlenecks, or a Markdown performance report."
---

# Session Performance Report

Build traceable performance report from logs. Exact facts stay exact. Derived
facts carry labels. Fluff die.

## Output

Write requested path. Default: `session_performance_report.md` under current workspace.
Use [report template](assets/session_performance_report.md). Keep section order
unless user requests otherwise.

Use caveman full style throughout report:

- terse technical prose;
- fragments allowed;
- no filler, praise, decorative text, or repeated conclusions;
- exact identifiers, model names, paths, timestamps, formulas preserved;
- human-readable Markdown tables preferred.

Format displayed measurements for fast human scanning:

- tokens: one decimal plus magnitude suffix: `1.2K`, `34.6M`, `7.8B`,
  `1.1T`, `2.3Q`; use `K`, `M`, `B`, `T`, `Q` for powers of 1,000;
- tokens below 1,000: integer without suffix, such as `842`;
- preserve exact token count in parentheses when rounding changes value:
  `12.3K (12,345 exact)`;
- time: compact compound duration, such as `2h05m07.042s`,
  `13m44.900s`, or `7.042s`;
- omit leading zero-valued hours and minutes;
- when hours exist, zero-pad minutes and seconds;
- when minutes exist without hours, do not pad minutes; zero-pad seconds;
- always show seconds with three decimal places, rounded to nearest millisecond;
- percentages: one decimal unless exact integer adds clarity;
- calculations and reconciliation use raw values, never displayed rounded values.

Use `⨽` for nested table rows. Example:

```markdown
| `parent-skill` | ... |
| ⨽ `nested-skill` | ... |
| `exec_command` batches | ... |
| ⨽ `nested-cli` | ... |
```

## Tables

Every Markdown table monospace-aligned for plain-text view (`cat`, terminal).
Rendered Markdown ignores padding — alignment costs nothing, reads well raw.

Rules:

- column width = max rendered cell length across all rows, including header;
  separator row never narrower than 3 dashes;
- pad every cell to column width; right-align numeric columns (`---:`),
  left-align text (`---`), center per template (`:---:`);
- separator row padded with dashes to match column widths, alignment colons
  preserved: right `-` × (w−1) + `:`, center `:` + `-` × (w−2) + `:`;
- mixed cell formats (`0`, `0.000s`, `31.505s apiMs`) pad as plain cells — no
  truncation, no normalization;
- empty cells stay empty, same width;
- verify before finish: `cat` the report — pipe columns line up vertically in
  every row; numeric columns flush right, text columns flush left.

## 1. Set scope

1. Find first user request belonging to measured task/session.
2. Find last completed turn belonging to it.
3. Exclude current performance-report turn to avoid recursive metrics.
4. Record UTC timestamps and local timezone when useful.
5. State whether wall span includes user/overnight idle gaps.

Never silently mix unrelated sessions or tasks. When sessions continue across
multiple rollout files, include each linked file and state selection rule.

## 2. Discover evidence

### 2.0 Detect agent (automatic)

Detect current agent first — each agent has its own session log format. Probe,
do not guess, do not ask:

1. **Qwen Code** — skill args file lives under `.qwen/tmp/s-<uuid>/` (e.g.
   `.qwen/tmp/s-00000000-0000-4000-8000-000000000000/qwen-skill-args-*.txt`);
   session id = `<uuid>`.
   Sources:
   - chat log: `~/.qwen/projects/<project-slug>/chats/<uuid>.jsonl`
     (project-slug derives from cwd, e.g. `-home-<user>-<project>`);
   - per-response tokens: `~/.qwen/usage/token-usage-<YYYY-MM>.jsonl` — fields
     `sessionId`, `model`, `inputTokens`, `outputTokens`, `cachedTokens`,
     `thoughtsTokens`, `totalTokens`, `apiDurationMs`, `timestamp`;
   - tool matching: assistant part `functionCall.id` ↔ `tool_result`
     `functionResponse.id`; timestamps per event; assistant parts carry
     `text` / `thought` / `functionCall`.
2. **Codex** — `.codex/sessions/**/rollout-*.jsonl`, `.codex/history.jsonl`,
   `.codex/logs_*.sqlite` (cwd or home).
3. **Fallback** — probe both glob families; pick newest matching session; if
   ambiguous, ask user for log path.

Detection is positive: report detected agent, session id, and log paths in
Scope. Never mix agent formats in one report.

Keep logs read-only.

### 2.1 Collect

- `task_started` / `task_complete` timestamps and durations;
- per-response token usage — Codex: `token_count.last_token_usage`; Qwen:
  usage-file fields above (sum per response, never cumulative snapshot);
- model, provider, effort, agent/thread identity — Qwen: `model` + `authType`
  in usage file; Codex: `turn_context`;
- matched tool call/output timestamps and tool names;
- user prompts, assistant milestones, and tool events for phase attribution;
- nested skill names from user inputs, skill resources, and workflow actions.

## 3. Calculate totals

### Time

```text
end-to-end span = last completed timestamp - first task timestamp
active wall     = sum measured active turn/phase spans
idle gaps       = end-to-end span - active wall
tool wall       = sum matched non-overlapping tool call/output durations
API/agent time  = active wall - tool wall
```

Call `API/agent time` derived unless complete provider request spans prove pure
API latency. Explain it includes model latency, reasoning, response generation,
and local orchestration.

### Tokens

Sum per-response usage, never final cumulative snapshots:

```text
input             = sum input_tokens
cached input      = sum cached_input_tokens
non-cached input  = input - cached input
output            = sum output_tokens
reasoning output  = sum reasoning_output_tokens
non-reasoning     = output - reasoning output
total             = input + output
```

State whether output includes reasoning. Calculate cache ratio.

## 4. Attribute performance

### Macro stages

Group by user turn or major task segment. Totals must reconcile.

### Workflow phases

Use timestamps from commentary milestones, tool events, artifacts, and commits.
Follow actual execution order even when numbered phases ran out of order.
Label attribution approximate when logs lack explicit phase IDs.

### Skills

Provide both:

- **exclusive primary attribution:** one primary skill/activity per turn; rows
  sum to session total;
- **inclusive nested coverage:** nested skills overlap; rows do not sum.

Use `⨽` under parent skills. Do not invent independent token cost for style or
reference skills when attribution cannot be isolated.

### Tools

Separate:

1. agent/API tools with exact matched call/output duration;
2. nested operations inside wrapper tools;
3. CLI batches launched inside shell tools.

Mark overlapping rows. Async utility continuation often appears under wait or
poll tools; do not present launch-call duration as complete process lifetime.

### Models and agents

Report model, provider, reasoning effort, agent count, API usage count, wall
time, and tokens. State whether subagents ran.

## 5. Explain performance

Rank biggest time and token costs. Name avoidable waste, such as:

- broad scans;
- failed tool routes;
- repeated polling;
- oversized context;
- rework after wrong inference;
- duplicate conversions;
- idle gaps confused with active work.

Give concrete optimization and expected effect. No generic advice.

## 6. Validate

Before finish:

- report exists and is non-empty;
- detected agent + session id + log paths stated in Scope;
- scope start/end and cutoff stated;
- all tables monospace-aligned (`cat` check, see §Tables);
- primary skill rows reconcile with total;
- phase API usages reconcile with model usage count;
- tool counts reconcile with matched calls;
- input/output totals match raw per-response sums;
- inclusive skill and CLI overlap labeled;
- derived API-time caveat present;
- current report turn excluded;
- nested rows use `⨽`;
- no secrets or raw proprietary log payload copied.

Report limitations. Never claim unavailable gateway-only latency or exact
nested-skill cost.
