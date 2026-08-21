# Strong Skill Review Rubric

Use during package audit and final strength audit. Score helps prioritization;
hard gates decide ship readiness.

## Contents

1. Scoring
2. Eight review lenses
3. Finding format
4. Final verdict

## Scoring

Score each lens:

- `0`: absent, wrong, or dangerous;
- `1`: usable but ambiguous, incomplete, or costly;
- `2`: explicit, testable, compact.

Strong target: at least 14/16, no zero, every hard gate pass. Score never
overrides hard-gate failure.

## Lenses

### 1. Trigger

- Description states capability and concrete invocation contexts.
- Positive, adjacent-negative, and ambiguous prompt route correctly.
- Body does not hide essential “when to use” rules.

Hard gate: wrong implicit invocation can cause unsafe or costly action.

### 2. Contract

- Inputs, discovery, outputs, side effects, dependencies, and done state clear.
- Non-goals and missing-input behavior explicit.
- User authority matches mutation.

Hard gate: skill can mutate outside user intent.

### 3. Main line

- Common case visible without reading every reference.
- Steps form one proof chain or explicit task router.
- Each step has one purpose and one proof object.

Hard gate: agent can skip prerequisite or finish before deliverable exists.

### 4. Checkpoints and gates

- Checkpoints contain observable facts or artifacts.
- Gates route `CONTINUE`, `RETURN`, `ENTER`, `STOP`, or `COMPLETE`.
- Returns name shortest repair step. Lanes return explicitly.

Hard gate: destructive, irreversible, or correctness-critical action lacks
precondition.

### 5. Domain integrity

- Domain invariants remain prominent.
- Observation, inference, and verdict stay separate where relevant.
- Fallback never weakens safety or evidence bar.

Hard gate: restructuring drops required safeguard or changes meaning.

### 6. Progressive disclosure

- `SKILL.md` holds core workflow and routing.
- References hold deep conditional knowledge.
- Scripts hold repeated deterministic logic.
- No duplicate source of truth or deep reference maze.

Hard gate: required instruction becomes undiscoverable.

### 7. Validation

- Official validator passes.
- Links, placeholders, metadata, scripts, and representative routes checked.
- Skipped test and dependency limit explicit.

Hard gate: package claims validation not performed.

### 8. Economy

- Every paragraph changes action, decision, evidence, or output.
- Repeated rules consolidated.
- Wording terse without losing constraints.

Hard gate: compression makes order, safety, or gate meaning ambiguous.

## Finding format

Use one line per issue:

```text
severity | location | broken contract | smallest fix
```

Severity:

- `BLOCKER`: hard gate fails;
- `HIGH`: common route wrong or evidence weak;
- `MEDIUM`: ambiguity, duplication, maintenance risk;
- `LOW`: polish with measurable value.

## Final verdict

Use one:

- `STRONG`: all hard gates pass; score at least 14/16.
- `USABLE`: core works; no unsafe blocker; score below strong bar.
- `WEAK`: one or more correctness, routing, or validation blockers.
- `INCONCLUSIVE`: package or evidence too incomplete to judge.

State score, failed gates, strongest feature, largest remaining risk, shortest
next fix.
