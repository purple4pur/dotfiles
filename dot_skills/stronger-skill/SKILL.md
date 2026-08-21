---
name: stronger-skill
description: "Create, review, or harden agent skills from a high-level systems view, then express each workflow through explicit Step, Checkpoint, and Gate contracts. Use when designing a new skill; auditing or restructuring SKILL.md; improving trigger metadata, progressive disclosure, resources, validation, or exception handling; converting loose instructions into an executable main line; or deciding whether a skill is strong enough to ship. Writes in terse caveman style while preserving technical precision."
---

# Stronger Skill

Make skill executable, compact, hard to misuse.

```text
intent
then contract
then package audit
then main line
then checkpoints and gates
then exception lanes
then implementation
then validation
```

High-level first. Detail only where failure costly.

## Operating rules

- Follow host platform skill-authoring rules. Use official scaffold, metadata,
  resource, and validation tools when available.
- Write user-facing analysis and skill prose in terse caveman style. Keep exact
  terms, paths, commands, code, and errors unchanged.
- Review only when user asks review. Edit only when user asks create, apply,
  fix, rewrite, or update.
- Preserve target domain behavior. Structure serves semantics, never replaces
  them.
- Read target `SKILL.md` fully. Read directly linked resources needed to judge
  workflow. Do not infer missing content from filenames.
- Preserve unrelated user changes. Never replace whole package blindly.
- Keep main `SKILL.md` under 500 lines where practical. Move conditional detail
  to direct references. Avoid deep reference chains.
- Prefer existing scripts, references, assets, and templates. Add resource only
  when repeated or fragile work needs it.
- Validate after edits. Strong prose without executable validation is weak.

## Model

Every main-line step owns one proof object.

- **Step:** bounded action. One purpose.
- **Checkpoint:** durable evidence produced by step.
- **Gate:** decision based only on checkpoint.
- **CONTINUE:** next main-line step.
- **RETURN:** named earlier step.
- **ENTER:** named conditional lane.
- **STOP:** blocker or review-only handoff.
- **COMPLETE:** output and validation contracts pass.

Gate must name route. “Continue as needed” is not gate.

For non-sequential skills, model decision lifecycle, not artificial domain
sequence:

```text
classify request
then choose operation
then validate operation evidence
then report
```

## Strength bar

Read [review-rubric.md](references/review-rubric.md) during Step 3 and Step 8.
Strong skill passes every hard gate:

- trigger precise enough for correct invocation;
- behavior and non-goals explicit;
- main line visible in one screen-sized scan;
- each step yields checkable evidence;
- each gate routes continue, return, lane, stop, or complete;
- destructive, costly, ambiguous, and missing-input cases gated;
- domain safeguards preserved;
- detail progressively disclosed;
- output contract testable;
- package validates; no placeholder remains.

No score can override failed hard gate.

## Main line

### 1. Frame task and authority

**Step**

Classify request:

- create new skill;
- review only;
- review then propose;
- review then apply;
- targeted update.

Record target path, requested name, user goal, allowed mutations, expected
deliverables, and named skills. Discover local instructions before editing.
Ask only when missing choice changes scope or destination. For new skill with
unspecified location, ask once; otherwise use explicit path.

**Checkpoint: `task_contract`**

Know mode, target, authority, deliverables, constraints, and validation
expectation.

**Gate**

- Target and authority clear: **CONTINUE Step 2**.
- New-skill location missing and unsafe to assume: **STOP** for location.
- Review-only request: allow reads, forbid writes; **CONTINUE Step 2**.
- Requested mutation exceeds authority: **STOP** and name needed permission.

### 2. Build skill contract

**Step**

Define what skill must do before judging structure:

- trigger phrases and task contexts;
- representative requests;
- inputs and discovery rules;
- outputs and side effects;
- dependencies and tools;
- hard safety or correctness invariants;
- expected failures and fallback policy;
- explicit non-goals.

For existing skill, derive contract from frontmatter, body, resources, user
request, and observed package behavior. Mark conflict; never silently choose.

**Checkpoint: `skill_contract`**

Write compact contract:

```text
Use when:
Must produce:
Must preserve:
Must never do:
Needs:
Done when:
```

**Gate**

- Contract concrete and testable: **CONTINUE Step 3**.
- Trigger broad but behavior narrow: repair contract before structure;
  **RETURN Step 2**.
- User intent conflicts with existing hard rule: **STOP** and expose conflict.
- Missing domain fact changes correctness: **STOP** for fact or mark review
  limit.

### 3. Audit package from high level

**Step**

Inspect package as system:

- frontmatter trigger quality;
- main workflow visibility;
- input, output, and mutation contracts;
- safety and evidence gates;
- progressive disclosure;
- scripts, references, assets, and duplication;
- optional host metadata alignment;
- validation and forward-test surface;
- dead text, stale paths, placeholders, contradictions.

Use [review-rubric.md](references/review-rubric.md). Separate fatal gap,
structural weakness, wording noise, and optional polish. Cite exact file and
section.

For create mode, inspect comparable local skills only when they provide useful
convention. Never cargo-cult package shape.

**Checkpoint: `package_audit`**

Record:

```text
Strengths:
Hard-gate failures:
Main-line breaks:
Duplication or missing resources:
Semantic risks:
Smallest useful change set:
```

**Gate**

- Review-only: **CONTINUE Step 4** to show proposed model, then stop at Step 5
  review gate.
- Existing package has unresolved semantic contradiction: **RETURN Step 2**.
- Package structure understood: **CONTINUE Step 4**.
- Target unreadable or missing in review mode: **STOP** with exact blocker.

### 4. Design main line

**Step**

Extract one dominant proof chain. Usually 5 to 9 steps. Start at user intent;
end at verified deliverable. Each step must narrow uncertainty or produce
required output.

Prefer:

```text
qualify
then discover
then act
then validate
then report
```

Keep policy above main line only when always active. Keep conditional work out
of main line. Merge steps sharing same proof object. Split steps with two
independent gates.

**Checkpoint: `workflow_model`**

Produce ordered step list. For each step name purpose, entry condition, proof
object, and next consumer.

**Gate**

- One dominant path covers common case: **CONTINUE Step 5**.
- Two unrelated common paths exist: use task router plus separate short main
  lines; **RETURN Step 4**.
- Step neither reduces uncertainty nor produces output: delete or merge it;
  **RETURN Step 4**.
- Domain is reference-only: model request-selection-validation lifecycle;
  **CONTINUE Step 5**.

### 5. Attach checkpoints, gates, and lanes

**Step**

For every step define:

```markdown
### N. Verb-led step

**Step**
<bounded action>

CHECKPOINT `proof_object`
<facts or artifact that must exist>

GATE
- <condition>: **CONTINUE Step N+1**.
- <repairable gap>: **RETURN Step N**.
- <special case>: **ENTER lane-name**.
- <hard blocker>: **STOP**.
```

Design gates from failure modes, not happy-path prose. Name shortest return.
Use lane only when condition is optional, rare, tool-specific, or deep.

Review mode must present proposed model and impact before any edit.

**Checkpoint: `gate_matrix`**

Every main step has one proof object and gate. Every gate outcome has named
route. Every lane has entry condition, work, exit evidence, and return step.

**Gate**

- Review-only: **STOP** with audit, proposed model, risks, and priority order.
- User authorized apply/create: **CONTINUE Step 6**.
- Gate depends on unobservable judgment: make checkpoint measurable;
  **RETURN Step 5**.
- Lane duplicates common path: merge into main line; **RETURN Step 4**.
- Main line buries domain safeguard: restore invariant above workflow;
  **RETURN Step 5**.

### 6. Implement smallest coherent package

**Step**

For new skill, use official scaffold when available. Create only needed
directories. For existing skill, edit smallest coherent set.

Author in this order:

1. frontmatter `name` and trigger-rich `description`;
2. invariant and routing rules;
3. main line with Step, Checkpoint, Gate;
4. conditional lanes;
5. output and validation contract;
6. direct references, scripts, or assets;
7. aligned optional host metadata.

Use imperative wording. Caveman compression: remove filler, not constraints.
Keep exact tool names and failure text. Never invent dependencies.

**Checkpoint: `implementation`**

Package contains no template text. Links resolve. Resources have clear caller.
Metadata matches behavior. Diff preserves required semantics and unrelated
changes.

**Gate**

- Coherent package complete: **CONTINUE Step 7**.
- Detail pushes main file near 500 lines: move conditional detail to direct
  reference; **RETURN Step 6**.
- Script repeats fragile logic: add deterministic script and test it;
  **RETURN Step 6**.
- New resource has no caller: delete it; **RETURN Step 6**.
- Semantic safeguard lost: restore before validation; **RETURN Step 6**.

### 7. Validate structure and behavior

**Step**

Run official skill validator. Then check:

- frontmatter only allowed fields;
- folder/name match;
- referenced files exist;
- no unresolved scaffold marker, placeholder, stale path, or broken example;
- line count and progressive disclosure sane;
- step, checkpoint, gate counts align;
- every lane returns;
- scripts execute on representative input;
- optional metadata prompt describes intended skill use;
- diff contains only intended files.

Build at least three mental or executable scenarios:

- normal request;
- missing/ambiguous input;
- tool or evidence failure.

For risky or complex skill, forward-test with raw task and minimal leaked
context when allowed. Never teach tester expected answer.

**Checkpoint: `validation_record`**

Record commands, results, scenario outcomes, known limits, and skipped tests
with reason.

**Gate**

- Validator and scenarios pass: **CONTINUE Step 8**.
- Structural validation fails: **RETURN Step 6**.
- Scenario takes wrong route: **RETURN Step 4 or 5**, whichever owns flaw.
- Test blocked by permission or unavailable dependency: report limit; do not
  claim pass.
- Forward test leaks intended solution: discard result; rerun clean or mark
  untested.

### 8. Audit strength and hand off

**Step**

Reapply [review-rubric.md](references/review-rubric.md) against final package.
Compare skill contract, implementation, and validation record. Reject strength
claim when any hard gate fails.

Report outcome first:

- created, reviewed, or updated path;
- main-line shape;
- hard gates added or preserved;
- resources created or moved;
- validation result;
- material limits;
- next action only when useful.

**Checkpoint: `handoff`**

User can locate package, understand main line, reproduce validation, and see
remaining risk.

**Gate**

- All hard gates pass; requested work complete: **COMPLETE**.
- Package works but hard gate remains: label not strong; **RETURN** to owning
  step or report blocker.
- Validation incomplete: report exact limit. Never say validated.
- User requested review only: **COMPLETE** without mutation.

## Exception lanes

### Trigger repair

Enter when frontmatter invokes too broadly, narrowly, or ambiguously. Rewrite
description with what skill does plus concrete use contexts. Test against one
positive, one adjacent-negative, and one ambiguous prompt. Return Step 2.

### Semantic preservation

Enter when restructuring existing skill. Build before/after invariant list:

```text
required behavior
forbidden behavior
hard stop
fallback
output contract
```

Resolve every deletion or relocation. Unexplained loss blocks apply. Return
Step 5 or 6.

### Progressive disclosure

Enter when main file too large or multiple variants coexist. Keep core
workflow and selection rules in `SKILL.md`. Move deep conditional detail to
one-level references. Put deterministic repeated logic in scripts. Return
Step 6.

### Blocked validation

Enter when validator, dependency, permission, or realistic test unavailable.
Run safe remaining checks. Record exact blocker and unverified claims. Return
Step 7; STOP if missing validation makes delivery unsafe.

## Output style

Use terse technical prose. State finding, evidence, fix. No praise filler.
Keep warnings and ordered destructive steps fully grammatical. Skill code and
commit text follow their native conventions.
