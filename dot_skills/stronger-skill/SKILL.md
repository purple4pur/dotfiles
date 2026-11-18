---
name: stronger-skill
description: >
  Create, review, or update agent skills. Use for skill design, SKILL.md audits,
  workflow restructuring, trigger repair, resource organization, validation,
  and output rules.
---

# Stronger skill

Build compact instructions with observable results and explicit decisions. Preserve the skill's domain behavior.

## Rules

- Edit only for a create, apply, fix, rewrite, or update request. Keep reviews read-only.
- Follow host skill-authoring rules. Use official scaffold and validation tools when available.
- Read the complete target `SKILL.md`. Read linked resources needed to assess its behavior.
- Preserve unrelated user changes. Change the smallest coherent set of files.
- Keep the main file below 500 lines where practical. Link conditional detail directly.
- Reuse existing resources. Add scripts only for repeated or fragile work.
- Use `write-docs` for prose, including resources, updates, and the handoff.
  Preserve the user's language and exact evidence, terms, paths, commands, code, and errors.

## Workflow

Frame task → define contract → audit package → design steps → attach gates → implement → validate → report.

Keep evidence in task notes or the deliverable. Create separate evidence files only when the task requires them.

A **Step** has one purpose. Its **Checkpoint** holds facts or an artifact.
Its **Gate** chooses a route from that evidence:

- **CONTINUE:** name the next step.
- **RETURN:** name the shortest repair step.
- **ENTER:** name a conditional lane.
- **STOP:** name the blocker or review handoff.
- **COMPLETE:** the output and validation contracts pass.

### 1. Frame the task

**Step:** Classify the request as create, review, review then propose, review then apply, or targeted update.
Record the target, name, goal, allowed changes, deliverables, named skills, and required validation. Read applicable local instructions.
Ask only when a missing choice changes scope or destination.

**Checkpoint: `task_contract`** — Mode, target, authority, constraints, and deliverables are known.

**Gate:** Clear authority and target: **CONTINUE Step 2**.
Missing new-skill location that cannot be safely inferred: **STOP** for the location.
Changes exceed authority: **STOP** and name the required permission.
Keep review-only work read-only through Step 5.

### 2. Define the skill contract

**Step:** Derive the contract from the request, frontmatter, body, resources, and observed package behavior.
Cover triggers, representative requests, inputs, discovery, outputs, side effects, dependencies, invariants, failures, fallbacks, and non-goals.
Record conflicts instead of silently choosing a rule.

```text
Use when:
Must produce:
Must preserve:
Must never do:
Needs:
Done when:
```

**Checkpoint: `skill_contract`** — Each requirement has a checkable result.

**Gate:** Contract concrete: **CONTINUE Step 3**.
Trigger and behavior differ: **ENTER Trigger repair**.
User intent conflicts with a hard rule: **STOP** with the conflict.
Missing domain facts affect correctness: **STOP** for the facts, or state the limit for a review.

### 3. Audit the package

**Step:** Apply [review-rubric.md](references/review-rubric.md).
Inspect triggers, workflow, contracts, safety, evidence, resources, duplication, optional metadata, validation, stale paths, placeholders, and contradictions.
For new skills, inspect comparable packages only when they supply a useful local convention.

**Checkpoint: `package_audit`** — Record strengths, failed hard gates, workflow gaps, semantic risks, and the smallest useful changes.
Classify findings as fatal gaps, structural weaknesses, wording noise, or optional polish. Cite the file and section.

**Gate:** Package understood: **CONTINUE Step 4**.
Semantic contradiction unresolved: **RETURN Step 2**.
Review target missing or unreadable: **STOP** with the exact blocker.

### 4. Design the main path

**Step:** Build one chain from intent to a verified deliverable. Usually use five to nine steps.
Give each step a purpose, entry condition, proof object, and next consumer.
Merge steps that share evidence. Remove steps that neither reduce uncertainty nor produce required output.
Keep always-active safeguards above the workflow. Put conditional detail below it.

For separate operations, use a router with short paths.
For reference skills, use the request-selection-validation lifecycle instead of an artificial procedure.

**Checkpoint: `workflow_model`** — The common path is visible in one scan and covers the skill contract.

**Gate:** Path covers the common case: **CONTINUE Step 5**.
Unrelated paths or ineffective steps remain: **RETURN Step 4** to route, merge, or remove them.

### 5. Attach checkpoints and gates

**Step:** Give every step one observable checkpoint and explicit routes.
Place prerequisites before the actions they guard. Design failure routes as well as the normal route.
Use this compact form:

```markdown
### N. Verb-led step

**Step:** Perform one bounded action after its prerequisites pass.

**Checkpoint: `evidence_name`** — State the required facts or artifact.

**Gate:** Evidence complete: **CONTINUE Step N+1**.
Repairable gap: **RETURN Step N**. Hard blocker: **STOP** with its cause.
```

Each lane needs an entry condition, action, exit evidence, and named return step.
Review mode must show the proposed workflow and impact before any edit.

**Checkpoint: `gate_matrix`** — Every step has evidence. Every decision and lane names its route.

**Gate:** Review-only: **STOP** with the audit, proposed model, risks, and priorities.
Authorized implementation: **CONTINUE Step 6**.
Unobservable gate or hidden safeguard: **RETURN Step 5**.
Lane duplicates the common path: **RETURN Step 4**.

### 6. Implement the package

**Step:** Use the official scaffold for new skills when available.
Write frontmatter, invariants, workflow, lanes, output and validation rules, resources, then optional metadata.
Use imperative sentences. Keep every constraint and exact tool name. Use only real dependencies.

**Checkpoint: `implementation`** — Metadata matches behavior, links resolve, resources have callers, and the diff preserves required semantics.
No unresolved template text remains.

**Gate:** Coherent implementation: **CONTINUE Step 7**.
Large main file or buried conditional detail: **ENTER Progressive disclosure**.
Deletion or relocation lacks preservation proof: **ENTER Semantic preservation**.
Lost safeguard or unused resource: **RETURN Step 6** to restore or remove it.
Repeated fragile logic: **RETURN Step 6** to add and test a deterministic script.

### 7. Validate the result

**Step:** Run the official validator when available. Check these package properties:

- Allowed frontmatter fields and matching folder name.
- Existing links, valid examples, and no stale paths or unresolved scaffold markers.
- Appropriate line count and direct resource links.
- Matching step, checkpoint, and gate counts, with a return from every lane.
- Representative script inputs and aligned optional metadata prompts.
- Intended files only in the diff, with domain safeguards preserved.
- Prose follows `write-docs`, with required syntax exceptions identified.

Test at least three scenarios: normal request, missing or ambiguous input, and tool or evidence failure.
For risky or complex skills, forward-test with a raw task and minimal context when allowed.
Keep the expected answer out of the test prompt.

**Checkpoint: `validation_record`** — Record commands, results, scenario routes, limits, and reasons for skipped checks.

**Gate:** Checks and scenarios pass: **CONTINUE Step 8**.
Structural failure: **RETURN Step 6**. Incorrect scenario route: **RETURN Step 4** for the workflow or **RETURN Step 5** for a gate.
Unavailable validator, dependency, permission, or realistic test: **ENTER Blocked validation**.
Test prompt reveals the solution: discard the result and **RETURN Step 7** for an independent test.
If another test is unavailable, **ENTER Blocked validation** and mark the behavior untested.

### 8. Audit and report

**Step:** Reapply [review-rubric.md](references/review-rubric.md).
Compare the contract, implementation, and validation record. A score never overrides a failed hard gate.
Report the path and outcome, workflow, safeguards, resource changes, validation, and material limits.
Include reproducible checks and a next action only when useful. Check the handoff against `write-docs`.

**Checkpoint: `handoff`** — The user can locate the package, assess its behavior, and reproduce validation.

**Gate:** Contract and hard gates pass: **COMPLETE**. A review completes without mutation.
Contract or trigger fails: **RETURN Step 2**. Workflow fails: **RETURN Step 4**.
Route fails: **RETURN Step 5**. Implementation or output fails: **RETURN Step 6**.
Validation incomplete: **ENTER Blocked validation**.

## Conditional lanes

### Trigger repair

**Entry:** The description invokes the skill too broadly, narrowly, or ambiguously.

**Step:** State the capability and concrete use contexts.
Check a positive request, an adjacent request outside scope, and an ambiguous request.

**Checkpoint: `trigger_cases`** — All three routes match the skill contract.

**Gate:** Cases pass: **RETURN Step 2**. Incorrect route: **RETURN Trigger repair**.

### Semantic preservation

**Entry:** A deletion or relocation lacks preservation proof.

**Step:** Map each original required behavior, forbidden behavior, hard stop, fallback, and output rule to its new location.
Preserve each rule or record an explicit user-authorized change.

**Checkpoint: `invariant_comparison`** — Every changed rule has a preservation location or authorized change.

**Gate:** Proof complete: **RETURN Step 6**. Gate needs repair: **RETURN Step 5**.
Domain meaning unresolved: **STOP** with the exact conflict.

### Progressive disclosure

**Entry:** The main file is too large, or conditional detail hides the common path.

**Step:** Keep core rules and routing in `SKILL.md`. Move conditional detail to direct references.
Use scripts for repeated deterministic work.

**Checkpoint: `resource_map`** — Each resource has a caller. Required rules remain visible, and links resolve without deep chains.

**Gate:** Map passes: **RETURN Step 6**. Required rule hidden: **RETURN Progressive disclosure**.

### Blocked validation

**Entry:** A required check cannot run.

**Step:** Complete the remaining safe checks. Record each blocker and the claim the missing check cannot support.

**Checkpoint: `validation_limit`** — Completed checks have results. Every skipped check has a reason and an unverified claim.

**Gate:** Blocker clears: **RETURN Step 7**.
Blocker remains: **STOP** with the partial result and exact validation limit.
