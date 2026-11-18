---
name: session-performance-report
description: >
  Measure AI session performance from local Qwen Code or Codex logs. Use for
  session statistics, token-cost or elapsed-time analysis, phase and skill
  attribution, tool or model breakdowns, bottlenecks, and Markdown performance
  reports.
---

# Session performance report

Build a traceable report from local logs. Preserve exact facts and label derived measurements.

## Scope and output

- Keep logs read-only. Measure one agent format per report.
- Exclude the current performance-report turn. State the session, boundaries, timezone, exclusions, and idle-gap policy.
- Use local evidence only. This skill produces no code changes or remote usage queries.
- Write the requested path. Default to `session_performance_report.md` in the workspace.
  Replace an existing report only when explicitly requested. Otherwise, choose and report a new name.
- Use [the report template](assets/session_performance_report.md). Preserve section order unless the user requests another order.
- Keep secrets and raw proprietary payloads out of the report.
- Report unavailable values as unavailable, not zero. Avoid unsupported gateway latency or isolated nested-skill cost claims.

## Workflow

Set scope → discover evidence → calculate → attribute → explain → validate.

### 1. Set the scope

**Step:** Identify the first request and last completed turn of the measured task or session.
Record UTC boundaries, local timezone, cutoff, and whether elapsed time includes user or overnight gaps.
For a session across rollout files, identify every linked file and state the selection rule.

**Checkpoint: `scope`** — Session ID, boundaries, exclusions, file-selection rule, and idle-gap policy.

**Gate:** Scope clear: **CONTINUE Step 2**.
Mixed sessions or ambiguous boundaries: **ENTER Scope selection**.

### 2. Discover evidence

**Step:** Detect the agent from workspace and task evidence. Use the sources and helpers below.
Collect completed task spans, per-response usage, model and provider, effort, agent identity, tool pairs, prompts, and milestones.
Collect nested skill names from requests, resources, and workflow actions.
Cross-check any parser digest against the raw records before using it.

**Checkpoint: `evidence`** — Agent, session ID, source paths, raw records, and parser cross-check results.

**Gate:** Evidence complete: **CONTINUE Step 3**.
Parser fails or format lacks a helper: **ENTER Manual evidence**.
Identity ambiguous: **ENTER Scope selection**.
No detectable source: **STOP** for the log path.

### 3. Calculate totals

**Step:** Use raw per-response values. Exclude cumulative snapshots, copied fork prefixes, and unchanged cumulative repeats.
Compute these totals:

```text
end-to-end span  = last completed timestamp - first task timestamp
active wall      = sum completed root turn spans or non-overlapping phase spans
idle gaps       = end-to-end span - active wall
tool wall        = union of matched tool call/output intervals within active spans
API/agent time   = active wall - tool wall

input            = sum input_tokens
cached input     = sum cached_input_tokens
non-cached input = input - cached input
output           = sum output_tokens
reasoning output = sum reasoning_output_tokens
non-reasoning    = output - reasoning output
total            = input + output
```

Use root-turn spans for session active wall. Report summed agent-active time separately because concurrent agents overlap.
Label `API/agent time` derived unless complete provider request spans prove pure API latency.
Explain that the derived value includes model latency, reasoning, response generation, and local orchestration.
State whether output includes reasoning. Calculate the cache ratio from raw input values.

**Checkpoint: `totals`** — Raw time and token totals reconcile with source records and their subset relations.

**Gate:** Totals reconcile: **CONTINUE Step 4**. Mismatch: **RETURN Step 2**.

### 4. Attribute performance

**Step:** Attribute measured time and tokens across the template's dimensions:

- Macro stages: user turns or major task segments.
- Workflow phases: actual execution order from milestones, tools, artifacts, and commits.
  Mark phase attribution approximate when logs lack explicit phase IDs.
- Exclusive primary skills: one primary skill or activity per turn. Rows sum to the session total.
- Inclusive nested skills: overlapping coverage. Rows do not sum, and nested rows use `⨽`.
  Mark unisolatable style or reference costs unavailable or approximate with an evidence basis.
- Tools: separate matched agent calls, nested wrapper operations, and shell CLI batches.
  Label overlaps. Launch duration alone does not measure an asynchronous process's full lifetime.
- Models and agents: model, provider, effort, agent count, API usage count, wall time, and tokens.
  State whether subagents ran.

**Checkpoint: `attribution`** — Exclusive rows reconcile. Inclusive coverage, overlaps, approximations, and derived values have labels.

**Gate:** Attribution reconciles: **CONTINUE Step 5**.
Wrong totals: **RETURN Step 3**. Wrong assignment: **RETURN Step 4**.
Unisolatable cost: label its evidence limit and **CONTINUE Step 5**.

### 5. Explain the costs

**Step:** Rank the largest time costs, token costs, and avoidable waste from measured evidence.
Consider broad scans, failed tool routes, repeated polls, excess context, rework, duplicate conversions, and idle-gap confusion.
Give a concrete improvement and its measurable or directional effect. Keep unsupported advice out of the report.

**Checkpoint: `findings`** — Ranked costs have evidence and specific improvements.

**Gate:** Findings supported: **CONTINUE Step 6**. Generic or unsupported findings: **RETURN Step 5**.

### 6. Write and validate the report

**Step:** Fill the template from the checkpoints. Replace each template field with evidence or an explicit unavailable value.
Apply the display and table rules below. Check these requirements before delivery:

- The report exists, is non-empty, and names the agent, session ID, paths, boundaries, and cutoff.
- Parser results match raw evidence. Input and output match raw per-response sums.
- Primary skill rows match totals. Phase API counts match model usage counts. Tool counts match matched calls.
- Inclusive skill, wrapper, and CLI overlaps have labels. Nested rows use `⨽`.
- Derived API time has its caveat. The current report turn remains excluded.
- Tables align in raw and rendered views. The report contains no secrets or raw proprietary payloads.
- Prose passes the output rules, and required syntax exceptions have an explanation.

**Checkpoint: `report`** — The report passes applicable checks and names all data-quality limits.

**Gate:** All checks pass: **COMPLETE**.
Scope or cutoff fails: **RETURN Step 1**. Evidence fails: **RETURN Step 2**.
Totals fail: **RETURN Step 3**. Attribution fails: **RETURN Step 4**.
Findings fail: **RETURN Step 5**. File, table, or prose fails: **RETURN Step 6**.
Required evidence unavailable: **STOP** with the partial report and exact limit.

## Sources and helpers

### Detect Qwen Code

Resolve the session ID from `.qwen/tmp/s-<uuid>/qwen-skill-args-*.txt` or an explicit selector.
Use these sources:

- Chats: `~/.qwen/projects/<project-slug>/chats/<uuid>.jsonl`. The project slug derives from the workspace path.
- Usage: `~/.qwen/usage/token-usage-<YYYY-MM>.jsonl`, filtered by `sessionId`.
- Usage fields: `model`, `authType`, `inputTokens`, `outputTokens`, `cachedTokens`, `thoughtsTokens`, `totalTokens`, `apiDurationMs`, and `timestamp`.
- Tool pairs: assistant `functionCall.id` matched to `tool_result` `functionResponse.id`, with event timestamps.
  Assistant parts contain `text`, `thought`, or `functionCall`.

Run `scripts/parse_qwen_session.py [--session <id>]` for turns, spans, tokens, tool pairs, aggregates, and union tool wall.
The helper excludes records at or after the last user message only for the current session.
It measures an explicitly selected foreign session fully. Apply the requested scope to that digest.
Missing automatic and explicit selectors produce an error.

### Detect Codex

Resolve the root from `CODEX_THREAD_ID`, `--session`, or `--log`.
Search `.codex/sessions/**/rollout-*.jsonl` in the workspace, then home.
Include only subagents linked by `sub_agent_activity.agent_thread_id`. Nearby timestamps do not establish session identity.
Use `task_started` and `task_complete` for completed spans, `token_count.last_token_usage` for usage, and `turn_context` for model metadata.

Run `scripts/parse_codex_session.py [--session <id> | --log <rollout.jsonl>] [--no-subagents]`.
The helper includes linked subagents by default and measures paired completed spans.
It excludes copied parent prefixes and unchanged cumulative token repeats, reconciles spans, and unions concurrent tool intervals.
The digest includes per-turn, agent, tool, nested-wrapper, and CLI evidence.

If detection fails, probe both log families and match workspace and task evidence.
Use Scope selection if multiple candidates remain. Recency alone does not establish identity.

Before delivering parser changes, test a multi-turn session, a current one-shot session, and a broken log path.
Expect an empty digest for the current incomplete one-shot session and a clear error for the broken path.
The helpers collect evidence. Scope decisions, attribution, findings, and improvements remain model work.

## Display measurements

Calculate and reconcile with raw values. Format only the displayed values:

- Tokens below 1,000: integers. Larger values: one decimal with `K`, `M`, `B`, `T`, or `Q` for powers of 1,000.
- If rounded tokens differ, include the exact count: `12.3K (12,345 exact)`.
- Time: compound duration, such as `2h05m07.042s`, `13m44.900s`, or `7.042s`.
  Omit leading zero hours and minutes. With hours, pad minutes and seconds to two digits.
  Without hours, leave minutes unpadded and pad seconds. Show three decimal places, rounded to the nearest millisecond.
- Percentages: one decimal, unless an exact integer is clearer.

## Align tables

Run `scripts/align_tables.py <file.md> [...]` after writing the report.
The helper edits tables in place, skips fenced code, and is idempotent. If it fails, align manually.

Set each column width to its widest rendered cell, including the header, with at least three separator dashes.
Pad text left and numeric columns right. Preserve alignment colons and every cell value, including mixed formats and empty cells.
The helper splits at every `|`, including escaped pipes.
Keep pipe values outside helper-formatted tables, or escape them and align the affected tables manually.
Read the final report with `cat`. Check vertical pipes, numeric alignment, and rendered tables.

## Conditional lanes

### Scope selection

**Entry:** Session, boundaries, or destination remain ambiguous.

**Step:** Resolve the choice from task evidence and state the selection rule.
If evidence cannot decide, ask for the missing path or boundary.

**Checkpoint: `scope_selection`** — Evidence or a user decision supports the selected scope.

**Gate:** Choice resolved: **RETURN Step 1**. Required answer absent: **STOP** with the missing input.

### Manual evidence

**Entry:** A parser fails, or the format has no supported helper.

**Step:** Record the error and read raw records under Step 2 and Sources and helpers.
Preserve scope, privacy, token, and overlap rules. Distinguish absent data from zero.

**Checkpoint: `manual_evidence`** — Raw records, source paths, and unresolved limits support the required metrics.

**Gate:** Evidence complete: **RETURN Step 2** without the failed helper.
Required records absent: **STOP** with the exact limit. Report only supported metrics.

## Output rules

Read [STE rules](../write-docs/references/ste.md) for English prose. This reference does not invoke the `write-docs` workflow.
Keep the user's language, exact evidence, identifiers, formulas, paths, timestamps, and native syntax.
STE takes precedence over caveman fragments. Check prose before delivery and revise failures.
Report only completed checks and name material limits.
