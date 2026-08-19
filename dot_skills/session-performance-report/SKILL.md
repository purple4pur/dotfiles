---
name: session-performance-report
description: "Measure and report AI session performance from local rollout/session logs: end-to-end and active wall time, derived API/agent time, tool time, input/cached/output/reasoning tokens, phase and skill attribution, tool usage, and model usage. Use when users ask for session statistics, debug performance, token-cost analysis, elapsed-time analysis, tool/model breakdowns, bottlenecks, or a Markdown performance report."
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

Use `⨽` for nested table rows. Example:

```markdown
| `parent-skill` | ... |
| ⨽ `nested-skill` | ... |
| `exec_command` batches | ... |
| ⨽ `fsdb2vcd` | ... |
```

## 1. Set scope

1. Find first user request belonging to measured task/session.
2. Find last completed turn belonging to it.
3. Exclude current performance-report turn to avoid recursive metrics.
4. Record UTC timestamps and local timezone when useful.
5. State whether wall span includes user/overnight idle gaps.

Never silently mix unrelated sessions or tasks. When sessions continue across
multiple rollout files, include each linked file and state selection rule.

## 2. Discover evidence

Prefer local session logs, typically:

```text
.codex/sessions/**/rollout-*.jsonl
.codex/history.jsonl
.codex/logs_*.sqlite
```

Use equivalent provider logs when Codex files are absent. Keep logs read-only.

Collect:

- `task_started` / `task_complete` timestamps and durations;
- `token_count.last_token_usage` per model response;
- `turn_context` model, provider, effort, and agent/thread identity;
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
- scope start/end and cutoff stated;
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
