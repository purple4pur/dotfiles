# Skill review rubric

Use this rubric for the package audit and final audit. Scores set priorities. Hard gates decide readiness.

## Score each dimension

- `0`: absent, incorrect, or dangerous.
- `1`: usable, but ambiguous, incomplete, or costly.
- `2`: explicit, checkable, and compact.

A strong skill scores at least 14 out of 16, with no zero and every hard gate passed.
A score never overrides a failed hard gate.

## Review dimensions

### 1. Trigger

Check that the description names the capability and concrete use contexts.
Test a positive request, an adjacent request outside scope, and an ambiguous request.
Keep essential invocation rules in the description.

**Hard gate:** Incorrect implicit invocation cannot cause unsafe or costly action.

### 2. Contract

Check inputs, discovery, outputs, side effects, dependencies, completion, non-goals, and missing-input behavior.
Match every mutation to user authority.

**Hard gate:** The skill cannot mutate outside the user's intent.

### 3. Main path

Check that the common path is visible without reading every reference.
Use one evidence chain or an explicit task router. Give each step one purpose and one proof object.

**Hard gate:** The agent cannot skip a prerequisite or finish before the deliverable exists.

### 4. Checkpoints and gates

Require observable facts or artifacts at each checkpoint.
Name every `CONTINUE`, `RETURN`, `ENTER`, `STOP`, and `COMPLETE` route.
Return to the shortest repair step. Give every lane an explicit return.

**Hard gate:** Destructive, irreversible, and correctness-critical actions have preconditions.

### 5. Domain integrity

Keep domain invariants prominent. Separate observations, inferences, and verdicts where the domain requires them.
Preserve safety and evidence requirements in fallbacks.

**Hard gate:** Restructuring preserves every required safeguard and its meaning.

### 6. Progressive disclosure

Keep core workflow and routing in `SKILL.md`. Use direct references for conditional detail and scripts for repeated deterministic work.
Give every resource a caller. Keep each rule in one authoritative location and avoid deep reference chains.

**Hard gate:** Required instructions remain discoverable.

### 7. Validation

Check the official validator, links, placeholders, metadata, scripts, and representative routes.
Record skipped checks and dependency limits.

**Hard gate:** Validation claims describe only checks that ran.

### 8. Economy

Keep paragraphs that affect action, decisions, evidence, or output. Consolidate repeated rules.
Shorten text while preserving constraints.

**Hard gate:** Compression preserves clear order, safeguards, and gate meaning.

## Record findings

Use one line per issue:

```text
severity | location | broken contract | smallest fix
```

Choose severity by impact:

- `BLOCKER`: a hard gate fails.
- `HIGH`: the common route is incorrect, or its evidence is weak.
- `MEDIUM`: ambiguity, duplication, or maintenance risk.
- `LOW`: polish with measurable value.

## Give the verdict

- `STRONG`: all hard gates pass, with a score of at least 14 out of 16 and no zero.
- `USABLE`: the core works without an unsafe blocker, but falls below the strong score.
- `WEAK`: a correctness, routing, or validation blocker remains.
- `INCONCLUSIVE`: the package or evidence is too incomplete to judge.

State the score, failed gates, strongest feature, largest remaining risk, and shortest useful next fix.
