---
name: cross-review
description: "Audit a repository, file, directory, or symbol with independent reviewers and agreed fixes. Use for cross review, cross review src/api.ts, cross review the reorder function, 全仓审查, or 交叉审查. Use nine review dimensions, plus a UI dimension when applicable and removed-behavior on diff rounds. Hold disputed findings for the user."
---

# Cross Review

Use independent review dimensions. Cross-check the evidence. Apply agreed fixes only.

## Contract

**Must produce:** consensus matrix (agreed / contested / rejected / held), agreed fixes committed one-per-change, verification evidence with explicit pass, failure, or blocked status, held-items report with evidence and options.

**Input:** optional scope after the trigger. Default = whole repo. Scope may be a file path, a directory, or a symbol (function/class/method name).

**Must preserve:** user authority over contested items; domain docs (SDD.md / DESIGN.md / README claims) as design-intent tiebreaker; one-commit-per-fix rhythm (record-each-step compatible); every finding's evidence.

**Must never do:** fix a contested item without explicit user decision; batch unrelated fixes into one commit; accept a bare "No issues found." without walked-evidence; claim verified without running build/tests; write to remotes/PRs.

**Needs:** host subagent capability, `interface-kit` skill (only when UI detected), `record-each-step` skill, `purple-coding-style` skill, project build/test commands.

**Done when:** the matrix, fix outcomes, verification status, and held items are delivered.
A blocked check or incomplete dimension limits the result. Never report that dimension as verified.

## Change execution

Enable `record-each-step` by default before making any agreed fix or other
review-driven change. Commit each logical change immediately on its managed
branch.

Apply `purple-coding-style` to every edited source region. Resolve the
project's formatter and run the smallest relevant formatting and verification
commands before committing.

## Agent roster (fixed names)

Whole-state rounds (the default) have no diff, so row 10 has no object there — 9 dimension agents is the correct count. Row 10 joins only on diff rounds.

| # | agent | dimension |
|---|---|---|
| 1 | `correctness` | line-by-line correctness: inverted conditions, missing await, None/null on reachable paths, race conditions, async blocking |
| 2 | `cross-file` | contract tracing: backend↔frontend schemas, dead exports/endpoints/columns, fields read-but-never-written |
| 3 | `security` | injection, SSRF, secrets, CORS, input validation, log forging; no boilerplate "add auth" without concrete exposure |
| 4 | `reuse` | dead weight (tags delete/dedupe/yagni/stdlib/native/shrink): duplication, dead code, speculative abstraction, hand-rolled stdlib |
| 5 | `altitude` | wrong-layer logic, bandaids, enumeration traps (unguarded external-response shapes) |
| 6 | `consistency` | sibling drift between parallel routers/components, misleading comments, asymmetric guards |
| 7 | `performance` | N+1, blocking I/O in async, missing indexes, rebuild-on-selection UI patterns, uncompressed payloads |
| 8 | `test-coverage` | specific untested critical paths; mutation-think existing tests (would they go red?) |
| 9 | `build-test` | deterministic: run ONE build + ONE test command per side, report commands + outcomes verbatim; source tags `[build]`/`[test]` |
| 10 | `removed-behavior` | **DIFF ROUNDS ONLY** — deleted/replaced lines: the invariant each removal enforced and where it is re-established; renamed exports compared as behavior; consumers of changed literals; schema migration/split-brain |

Plus:

- `interface-kit` — UI lens (contrast ratios computed, touch targets, keyboard, ARIA, motion). Runs **only when Step 1 detects UI**.
- Over-engineering is not a separate agent: row 4 (`reuse`) owns the ponytail dead-weight lens end to end (agent-briefs.md row 4). The standalone `ponytail*` skills are upstream lineage only — not invoked.

Launch rules shared by all finder agents (1-8, interface-kit; build-test exempt — it runs commands, not review):

- Read the full files in scope; small repos read everything, large repos get a scope map from Step 1.
- Every finding carries: `file:line`, severity (Critical / Suggestion / Nice to have), what's wrong, **concrete failure scenario** (trigger → wrong outcome, or concrete cost), suggested fix, confidence. A Suggestion without a scenario is dropped by the agent itself.
- Evidence rule: verify usage claims by grep before calling something dead; compute (not eyeball) any metric you cite (contrast ratios, payload sizes).
- Empty return must be `No issues found — <what you examined>`. A bare "No issues found." lacks review evidence.
- Suspected Critical you cannot pin down: report with `Confidence: low`, never silently drop.
- Use the host launch, result, and wait tools. Collect every result before cross-check.
- Keep reviewers read-only. Only the orchestrator applies fixes or commits.
- Give each reviewer the STE output rules. Preserve quoted evidence exactly.
- If slots cannot hold the roster, run independent reviewers in batches. Keep all dimensions and collect every result.

## Main line

Resolve scope → collect reviews → cross-check evidence → apply agreed fixes → verify → report.

### 1. Qualify the round

**Step**

Resolve the scope first. Default = whole repo (scope map = all source files). Otherwise:

- **file** → scope map = that file.
- **directory** → scope map = the subtree's source files (respect ignore files; exclude vendored/generated).
- **symbol** (function/class/method) → grep the name to locate the definition; scope map = the enclosing file, plus one hop of direct callers/callees for the cross-file lens. Record `symbol → file:line-range` in the plan so every agent brief can state it.

Roster trimming by scope: build-test always runs project-level commands regardless of scope; interface-kit runs only when the scope map contains UI files; every other lens reviews the scope map with the shared rules (greps may reach anywhere, reads stay in scope).

Collect the mode, UI detection, build/test commands per side, domain document, and test inventory.
Use whole-state mode by default. A diff target adds `removed-behavior`.
Find commands in project manifests. Use SDD.md, DESIGN.md, or README claims for design intent.
Record initial branch, HEAD, and user changes. `record-each-step` owns branch setup before agreed edits.
For a diff round, create a unique temporary directory before capture. Record the complete diff path in the plan.

**Diff rounds only:** resolve the base ONCE yourself (the user-named Git revision or the verified project main branch — never let agents pick), capture the diff to a file with pinned flags (`git diff --unified=3 <base> > /tmp/<unique-round>/cross-review-diff.txt`, or `git diff <base> -- <paths>` for scoped rounds), and build the scope map from the changed files intersected with the requested scope. Hand every agent the diff-file path; agents never run `git diff` themselves (wrong base = phantom regressions; shell output truncates large diffs).

**Checkpoint: `review-plan`**

Written plan: initial branch and user-change inventory, pinned diff base when applicable, roster list (rows 1-9 + interface-kit? + row 10 on diff rounds), scope map for large repos, test commands, domain doc path.

**Gate**

- Plan complete: **CONTINUE Step 2**.
- Scope unresolvable (symbol not found, path does not exist, scope matches nothing after ignore rules): **STOP** — ask the user for the intended target; never silently review the whole repo instead.
- No test command found for a side: keep it in plan as `verification: blocked — <reason>`; **CONTINUE Step 2** (build-test agent reports the absence as a deterministic fact).
- No domain doc found: mark `design-judge: none` (cross-check relies on code evidence only); **CONTINUE Step 2**.

### 2. Fan out independent reviewers

**Step**

Launch all planned reviewers through the host subagent tools. Run them in parallel within the available slots.
If capacity is smaller than the roster, queue the remaining reviewers in independent batches.
If subagent tools are absent, **STOP** with the exact limit. Do not simulate independent consensus.
Give each reviewer its [dimension brief](references/agent-briefs.md), shared rules, scope map, and repository root.
Give `build-test` the commands. Require exact results with `[build]` and `[test]` tags. Keep all reviewers read-only.

**Checkpoint: `finder-results`**

Every planned reviewer returned findings or an empty result with review evidence. Failed dimensions have an explicit status.

**Gate**

- All substantive: **CONTINUE Step 3**.
- An agent returned bare "No issues found." with no walked-evidence, or returned near-instantly with almost no output: relaunch that ONE agent once with the missing evidence named; second bare return → take it and record its dimension as `unreviewed lens` in the matrix (caps any "clean" claim). **CONTINUE Step 3**.
- An agent failed/errored (tool crash, timeout): relaunch once; second failure → same `unreviewed lens` treatment. **CONTINUE Step 3**.

### 3. Cross-check into a consensus matrix

**Step**

Merge findings with the same defect, location, and cause. Keep the highest severity and every reporting dimension.
Check counter-evidence and design conflicts before agreement. Assign each entry one outcome:

- **agree** — flagged by ≥2 lenses, OR flagged once with executed evidence (probe output, failing command, computed metric) from the finder.
- **rejected** — claim disproved by execution or direct counter-evidence (quote the decisive line/output). Rejected entries are reported, never fixed.
- **contested** — lenses conflict, OR a lens conflicts with the domain doc (e.g. "dead column" vs SDD listing it as planned surface). Record both sides + the doc citation.
- **held** — one dimension reports a plausible defect without decisive executed evidence. Hold it with the evidence and behavior risk.

Probe runnable claims that decide agreement or rejection. Use temporary fixtures and restore only probe-owned changes.
Compare status with the initial user-change inventory. Preserve user changes. Check each decisive claim against the code.

**Checkpoint: `consensus-matrix`**

Matrix with four sections, each entry carrying lenses-that-flagged, evidence, and (for contested) the doc citation.

**Gate**

- Every entry ruled: **CONTINUE Step 4**.
- A "fact" rests only on prose with no code check and matters for a fix decision: probe it now; **RETURN Step 3**.
- Two lenses produce genuinely different scopes (not duplicates): both stay as separate entries; **CONTINUE Step 4**.

### 4. Fix what everyone agrees on

**Step**

Apply agreed fixes only. Enable `record-each-step` before the first edit, then
apply `purple-coding-style` to each affected source region. One logical fix =
one commit (`fix(scope): ...` conventional message) so each fix is revertible.
Skip nothing silently: a finding you decline to fix despite agreement gets
outcome `skipped` + reason in the report.

**Checkpoint: `fix-log`**

Commit list (one per fix) + per-finding outcome (fixed / skipped+reason).

**Gate**

- Managed task changes committed, every agreed finding has an outcome: **CONTINUE Step 5**.
- User changes prevent safe branch setup: record agreed fixes as blocked; **CONTINUE Step 5** without edits.
- A "fix" would change public behavior/API beyond the finding's scenario (verb rename, format unification visible to users): reclassify as contested, request the user decision through the host question tool or the report; **RETURN Step 3**.
- A fix turns out wrong mid-edit (breaks a test, contradicts code reality): revert that edit, move finding to rejected/held with the counter-evidence; **RETURN Step 3**.
- No agreed fixes: **CONTINUE Step 5**. Reuse Step 2 verification if it covered the required checks and the tree did not change.

### 5. Verify for real

**Step**

Run the required project verification: build per side, full unit suites, backend tests, and end-to-end tests when fixes touched UI.
Reuse completed checks only if the relevant tree and fixtures did not change.
Use fresh temporary fixtures for end-to-end tests. Quote pass counts and failure text exactly.

**Checkpoint: `verification-evidence`**

Command list + outcomes (pass counts / failure text).

**Gate**

- All green: **CONTINUE Step 6**.
- Existing code failure: record the failure and affected scope; **CONTINUE Step 6** with a failed status.
- Red caused by a fix: fix the code, not the test — unless the test pinned deliberately-changed behavior (then update the test in its own commit, citing the behavior change). **RETURN Step 4**.
- Verification blocked (no commands, env failure): record `verification: blocked — <exact reason>`; **CONTINUE Step 6**. Never claim verified.

### 6. Report and hand off

**Step**

Check report prose against the STE rules below. Deliver the consensus matrix, fix log with commit hashes, and verification evidence.
For each held or contested item, provide the evidence, competing interpretations, and two or three concrete options.
Give held items sufficient detail for a user decision. Wait for that decision before further edits.

**Checkpoint: `cross-review-report`**

Report delivered; user can decide each held item from the report alone.

**Gate**

- Report complete, no unreviewed lens hidden: **COMPLETE**.
- Any `unreviewed lens` from Step 2: named explicitly in the report with its consequence (that dimension unverified) — still COMPLETE, but the cap is visible.
- User approves held or contested items: **RETURN Step 4** with only those items, then run Step 5.

## Evidence and decision rules

- **Design conflict**: one lens demanding deletion of something the domain doc plans for = contested, not agreed. The doc wins until the user says otherwise.
- **Executed evidence**: a claim killed by running code is dead regardless of how many lenses believed it; a claim surviving a probe is alive regardless of lens count.
- **Verification claims**: use results from commands that ran on the relevant tree. Report failed or blocked checks explicitly.
  A complete report does not establish that blocked dimensions or failed fixes passed.
- **Commit scope**: one fix per commit permits a separate revert and an accurate squash message.

## Output language and validation

Read [STE rules](../write-docs/references/ste.md) before you write English prose.
This shared reference belongs to the local skill bundle. It does not invoke the `write-docs` workflow.
Use concise, grammatical sentences in status updates, explanations, and the final report.
Keep the user's requested language. Preserve exact evidence, technical terms, paths, commands, code, and required formats.
Keep native commit syntax. Apply STE to explanatory comments where source conventions permit it.
STE takes precedence over caveman fragments within the remaining style choices.
Before each delivery, check sentence length, articles, voice, stable terms, conditions, and negations.
If prose fails the check, revise it before delivery. Report material validation limits. Claim only checks that ran.
