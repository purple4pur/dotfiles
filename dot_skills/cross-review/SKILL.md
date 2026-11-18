---
name: cross-review
description: >
  Audit a repository, file, directory, symbol, or diff with independent reviewers
  and agreed fixes. Use for cross review, cross review src/api.ts, cross review
  the reorder function, 全仓审查, or 交叉审查.
---

# Cross review

Collect independent reviews, check their evidence, and apply agreed fixes. Hold disputed changes for the user's decision.

## Contract

- Default scope is the whole repository. Accept a path, directory, symbol, or diff target.
- Produce a consensus matrix, one commit per agreed logical fix, verification evidence, and held-item options.
- Preserve user changes and every finding's evidence. Keep reviewers read-only. Only the orchestrator edits and commits.
- Enable `record-each-step` before review-driven changes. Apply `purple-coding-style` to edited source regions.
  Run the relevant formatter and checks before each commit.
- Use SDD.md, DESIGN.md, or README claims as design intent. Incompatible changes remain contested until the user decides.
- Keep remote writes and PR changes outside scope. This skill requires host subagent tools.
- A complete report can include failed checks or incomplete dimensions. Label these limits instead of claiming verification.

## Reviewer roster

Use every base dimension. Add UI only when the scope contains UI. Add removed behavior only for diff rounds.
Run reviewers within the host slot limit, in independent batches when required.

| Agent | Dimension |
|---|---|
| `correctness` | Reachable errors, boundaries, null values, races, and async behavior. |
| `cross-file` | Producer and consumer contracts, schemas, fields, exports, and endpoints. |
| `security` | Concrete exposure across trust boundaries. |
| `reuse` | Unnecessary code, dependencies, duplication, and abstraction. |
| `altitude` | Layer boundaries, upstream workarounds, and external response shapes. |
| `consistency` | Sibling drift, asymmetric guards, and misleading comments. |
| `performance` | Query, I/O, payload, memory, and UI costs under stated load. |
| `test-coverage` | Specific untested paths and defects existing tests would miss. |
| `build-test` | One build and one test command per side, with deterministic results. |
| `removed-behavior` | Diff only: preserved invariants, changed consumers, and migration needs. |
| `interface-kit` | UI only: accessibility, typography, layout, color, and motion. |

Use [agent-briefs.md](references/agent-briefs.md) for finding fields, scope rules, and each dimension's instructions.
The `reuse` dimension owns the over-engineering lens. Do not invoke the standalone `ponytail*` skills for this review.

## Workflow

Resolve scope → collect reviews → decide findings → apply agreed fixes → verify → report.

### 1. Plan the round

**Step:** Resolve the target and construct a scope map:

- Whole repository: all source files.
- File: the named file.
- Directory: source files in that subtree, respecting ignore rules and excluding vendored or generated files.
- Symbol: locate its definition with `rg`. Record the enclosing file and `symbol → file:line-range`.
  Include one hop of direct callers and callees for the cross-file lens.

Use whole-state mode unless a diff is requested.
Record UI detection, roster, build and test commands per side, test inventory, and design document.
Discover commands from project manifests. Build-test uses project-level commands even for a narrow scope.
Record the initial branch, HEAD, and user changes. `record-each-step` handles branch setup before fixes.

For a diff round, resolve the user-named base or verified main branch once.
Capture the diff in a unique temporary directory, using `git diff --unified=3 <base>` with explicit scoped paths when needed.
Intersect changed files with requested scope. Record the base and complete diff path.
Give every reviewer that file. Reviewers never capture their own diff or choose another base.

**Checkpoint: `review_plan`** — Scope map, mode, roster, pinned diff when applicable, commands, design evidence, and initial user state.

**Gate:** Plan complete: **CONTINUE Step 2**.
Target missing, symbol unresolved, or scope empty: **STOP** for the intended target. Keep the requested scope.
Missing check command: record `verification: blocked — <reason>` and **CONTINUE Step 2**.
Missing design document: record `design-judge: none` and **CONTINUE Step 2** with code evidence only.

### 2. Collect independent reviews

**Step:** Require host subagent tools before launching reviews.
Give each planned reviewer its dimension brief, repository root, scope map, shared rules, and supplied diff when applicable.
Give build-test the selected commands and require `[build]` and `[test]` results.
Give reviewers the STE output rules and preserve quoted evidence exactly.
Collect every result before cross-checking. Keep all reviewers read-only.

**Checkpoint: `finder_results`** — Every dimension has findings, an evidence-backed empty result, or an explicit failure status.

**Gate:** Results complete: **CONTINUE Step 3**.
Subagent tools absent: **STOP** with the exact limit. Do not simulate independent consensus.
Failed reviewer or unsupported empty response: relaunch that reviewer once with the missing evidence named.
After a second failure, record `unreviewed lens` and **CONTINUE Step 3**. This limits any clean-result claim.
Treat near-instant returns with almost no output as unsupported results.

### 3. Build the consensus matrix

**Step:** Merge findings only when defect, location, and cause match.
Keep the highest severity and every reporting dimension. Check code, counter-evidence, and design conflicts.
Probe runnable claims that determine agreement or rejection, using temporary fixtures.
Restore only probe-owned changes and compare status with the initial user-change inventory.

Assign each finding an outcome:

- **agreed:** at least two lenses report it, or one finder supplies decisive executed evidence.
- **rejected:** execution or direct counter-evidence disproves it. Quote the decisive line or output.
- **contested:** lenses conflict, or a finding conflicts with design intent. Record both sides and any document citation.
- **held:** one lens reports a plausible defect without decisive executed evidence.

Executed counter-evidence overrides votes. Keep distinct defects separate even when their scopes overlap.

**Checkpoint: `consensus_matrix`** — All four outcomes contain reporting dimensions, evidence, and required design citations.

**Gate:** Every finding ruled: **CONTINUE Step 4**.
A decisive claim lacks a code check: probe it and **RETURN Step 3**.

### 4. Apply agreed fixes

**Step:** Require agreement or an explicit user decision before each fix.
Enable `record-each-step`, apply `purple-coding-style`, and commit one logical change at a time.
Use a Conventional Commit such as `fix(scope): <summary>`.
Give every agreed item a fixed, skipped, or blocked outcome with a reason.

**Checkpoint: `fix_log`** — Per-finding outcomes and one commit hash per logical fix.

**Gate:** All agreed items accounted for and task changes committed: **CONTINUE Step 5**.
No agreed fixes: **CONTINUE Step 5**.
User changes block safe branch setup: record blocked fixes and **CONTINUE Step 5** without edits.
Fix changes public behavior beyond the finding's scenario: mark contested and **RETURN Step 3** for a user decision.
Fix proves wrong: undo only that edit, record counter-evidence as rejected or held, and **RETURN Step 3**.

### 5. Verify the result

**Step:** Run required project verification: builds per side, full unit suites, backend tests, and end-to-end tests for UI fixes.
Reuse prior checks only when the relevant tree and fixtures are unchanged.
Use fresh temporary end-to-end fixtures. Preserve exact pass counts and failure text.

**Checkpoint: `verification_evidence`** — Commands and explicit passed, failed, or blocked results.

**Gate:** Checks pass: **CONTINUE Step 6**.
Existing failure: record its affected scope and **CONTINUE Step 6** with failed status.
Fix causes failure: **RETURN Step 4** to repair the fix.
Update a test only for deliberately changed behavior, in a separate commit that cites the change.
Environment or command blocked: record `verification: blocked — <exact reason>` and **CONTINUE Step 6**.

### 6. Report the review

**Step:** Deliver the consensus matrix, fix log with hashes, and verification evidence.
For every held or contested item, give the evidence, competing interpretations, and two or three concrete options.
Name every unreviewed dimension and its consequence. Apply the output rules below.

**Checkpoint: `cross_review_report`** — The user can assess results and decide each held item from the report alone.

**Gate:** Report complete with visible limits: **COMPLETE**.
Missing evidence or hidden dimension: **RETURN Step 6**.
User approves held or contested items: **RETURN Step 4** for those items, then run Step 5.
Wait for that decision before editing them.

## Output rules

Read [STE rules](../write-docs/references/ste.md) for English prose. This reference does not invoke the `write-docs` workflow.
Keep the user's language, exact evidence, terms, paths, commands, code, and native commit syntax.
Apply STE to explanatory comments where source conventions permit it. STE takes precedence over caveman fragments.
Check prose before delivery and revise failures. Report material limits and only checks that ran.
