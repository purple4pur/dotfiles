# Session performance report

## Scope and methodology

Measured session:

- Start: `<UTC timestamp>`, `<first task>`.
- End: `<UTC timestamp>`, `<last completed task>`.
- Excludes current performance-report turn.
- Sources: `<rollout/session log paths or glob>`.
- Token source: `<exact usage event>`.
- Tool-time source: `<matched call/output timestamps>`.
- Active-time source: `<task spans / attributed phase bands>`.

`API time` calculation:

```text
API/agent time = active wall time - matched tool wall time
```

State derived-versus-exact limitation. State exclusive and inclusive
attribution rules.

## Overall summary

| Metric | Value | Share |
|---|---:|---:|
| End-to-end elapsed span | `<duration>` | 100% |
| Active task wall time | `<duration>` | `<percent>` |
| User/overnight idle gaps | `<duration>` | `<percent>` |
| Matched tool wall time | `<duration>` | `<percent of active>` |
| Derived API/agent time | `<duration>` | `<percent of active>` |
| Model responses/API usages | `<count>` | — |
| Tool calls | `<count>` | — |
| Commits, if relevant | `<count>` | — |

## Token usage

| Token class | Tokens | Notes |
|---|---:|---|
| Input | `<count>` | Includes cached input |
| Cached input | `<count>` | `<percent>` of input |
| Non-cached input | `<count>` | Input minus cached subset |
| Output | `<count>` | State reasoning inclusion |
| Reasoning output | `<count>` | Output subset |
| Non-reasoning output | `<count>` | Output minus reasoning subset |
| Total | `<count>` | Input plus output |

One terse interpretation sentence.

## Macro-stage performance

| Stage | Active wall | Tool wall | API/agent | Input | Output | Reasoning | Model calls |
|---|---:|---:|---:|---:|---:|---:|---:|
| `<stage>` | `<duration>` | `<duration>` | `<duration>` | `<count>` | `<count>` | `<count>` | `<count>` |

## Performance by workflow phase

State actual-order and attribution rule.

| Phase | Active wall | Tool wall | API/agent | Input | Output | Reasoning | API calls | Tool calls |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `<phase: work>` | `<duration>` | `<duration>` | `<duration>` | `<count>` | `<count>` | `<count>` | `<count>` | `<count>` |

## Performance by skill

### Exclusive primary attribution

| Primary skill/activity | Active wall | Tool wall | API/agent | Input | Output | Reasoning | API calls |
|---|---:|---:|---:|---:|---:|---:|---:|
| `<primary skill>` | `<duration>` | `<duration>` | `<duration>` | `<count>` | `<count>` | `<count>` | `<count>` |

### Inclusive nested-skill coverage

Rows overlap. Do not sum.

| Skill | Covered wall | Tool wall | API/agent | Input | Output | Reasoning | Calls | Role |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| `<parent skill>` | `<duration>` | `<duration>` | `<duration>` | `<count>` | `<count>` | `<count>` | `<count>` | `<role>` |
| ⨽ `<nested skill>` | `<duration>` | `<duration>` | `<duration>` | `<count>` | `<count>` | `<count>` | `<count>` | `<role>` |

## Performance by tool

### Agent API tools

| Tool | Calls | Tool wall | Average | Share of tool wall |
|---|---:|---:|---:|---:|
| `<tool>` | `<count>` | `<duration>` | `<duration>` | `<percent>` |

### Operations inside wrapper tool

Rows can overlap.

| Nested operation | Calls containing operation | Matched wrapper wall |
|---|---:|---:|
| ⨽ `<operation>` | `<count>` | `<duration>` |

### Major CLI batches

State batch-count and async-lifetime limitations.

| CLI/tool | Shell batches | Launch/matched wall |
|---|---:|---:|
| `<parent shell operation>` | `<count>` | `<duration>` |
| ⨽ `<CLI>` | `<count>` | `<duration>` |

## Performance by agent model

| Model | Provider | Effort | Agent instances | API usages | Active wall | Input | Cached input | Output | Reasoning |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|
| `<model>` | `<provider>` | `<effort>` | `<count>` | `<count>` | `<duration>` | `<count>` | `<count>` | `<count>` | `<count>` |

State subagent usage.

## Main performance findings

1. `<largest time cost>`
2. `<largest token cost>`
3. `<largest avoidable waste>`
4. `<cache/context finding>`
5. `<idle-versus-active finding>`

## Optimization opportunities

| Change | Expected impact |
|---|---|
| `<specific change>` | `<measurable or directional impact>` |

## Data-quality limits

- `<exact metrics>`
- `<derived metrics>`
- `<attribution limits>`
- `<overlap limits>`
- Current performance-report turn excluded.
