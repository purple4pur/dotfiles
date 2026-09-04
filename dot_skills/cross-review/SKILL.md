---
name: cross-review
description: Multi-reviewer audit with consensus fixing. Runs 9 dimension agents (row 4 reuse carries the over-engineering dead-weight lens) (+ interface-kit when UI exists) as parallel subagents over a review scope — whole repo by default, or a file, directory, or function/class the user names ("cross review", "cross review src/api.ts", "cross review the reorder function", "全仓审查", "交叉审查 src/api.ts"). Cross-checks all findings, fixes only what everyone agrees on, holds contested items for the user.
---

# Cross Review

Independent lenses, cross-checked truth, consensus-only fixes.

## Contract

**Must produce:** consensus matrix (agreed / contested / rejected / held), agreed fixes committed one-per-change, green verification evidence, held-items report with evidence and options.

**Input:** optional scope after the trigger. Default = whole repo. Scope may be a file path, a directory, or a symbol (function/class/method name).

**Must preserve:** user authority over contested items; domain docs (SDD.md / DESIGN.md / README claims) as design-intent tiebreaker; one-commit-per-fix rhythm (record-each-step compatible); every finding's evidence.

**Must never do:** fix a contested item without explicit user decision; batch unrelated fixes into one commit; accept a bare "No issues found." without walked-evidence; claim verified without running build/tests; write to remotes/PRs.

**Needs:** subagent capability (`review-agent` type), `interface-kit` skill (only when UI detected), project build/test commands.

**Done when:** matrix delivered, fixes landed, verification green, held items listed.

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
- Empty return must be `No issues found — <what you examined>`. Bare "No issues found." is a whiff.
- Suspected Critical you cannot pin down: report with `Confidence: low`, never silently drop.
- Every agent runs inline (`run_in_background: false`) so findings return to the orchestrator. Fire-and-forget agents never deliver findings — the round stalls in cross-check with nothing to rule on.

## Main line

### 1. Qualify the round

**Step**

Resolve the scope first. Default = whole repo (scope map = all source files). Otherwise:

- **file** → scope map = that file.
- **directory** → scope map = the subtree's source files (respect ignore files; exclude vendored/generated).
- **symbol** (function/class/method) → grep the name to locate the definition; scope map = the enclosing file, plus one hop of direct callers/callees for the cross-file lens. Record `symbol → file:line-range` in the plan so every agent brief can state it.

Roster trimming by scope: build-test always runs project-level commands regardless of scope; interface-kit runs only when the scope map contains UI files; every other lens reviews the scope map with the shared rules (greps may reach anywhere, reads stay in scope).

Then collect round inputs: mode (whole-state default; a diff target adds `removed-behavior` to the roster), UI detection (from the scope map), build/test commands per side (package.json scripts, pyproject/uv, Makefile), domain doc (SDD.md / DESIGN.md — the design-intent judge), existing test suite inventory. Branch setup: if record-each-step is active it owns the branch; otherwise work on the current branch and say so.

**Diff rounds only:** resolve the base ONCE yourself (the domain doc, the main branch, or the user-named base — never let agents pick), capture the diff to a file with pinned flags (`git diff --unified=3 <base> > /tmp/cross-review-diff.txt`, or `git diff <base> -- <paths>` for scoped rounds), and build the scope map from the changed files intersected with the requested scope. Hand every agent the diff-file path; agents never run `git diff` themselves (wrong base = phantom regressions; shell output truncates large diffs).

**Checkpoint: `review-plan`**

Written plan: roster list (rows 1-9 + interface-kit? + row 10 on diff rounds), scope map for large repos, test commands, domain doc path.

**Gate**

- Plan complete: **CONTINUE Step 2**.
- Scope unresolvable (symbol not found, path does not exist, scope matches nothing after ignore rules): **STOP** — ask the user for the intended target; never silently review the whole repo instead.
- No test command found for a side: keep it in plan as `verification: blocked — <reason>`; **CONTINUE Step 2** (build-test agent reports the absence as a deterministic fact).
- No domain doc found: mark `design-judge: none` (cross-check relies on code evidence only); **CONTINUE Step 2**.

### 2. Fan out independent reviewers

**Step**

Launch ALL rostered agents (rows 1-9, plus row 10 on diff rounds, plus interface-kit if planned) in ONE response as parallel subagents — no sequencing. Each gets: its dimension brief (from [references/agent-briefs.md](references/agent-briefs.md) plus the shared launch rules), the scope map, the repo root. build-test additionally gets: run commands, report outcomes verbatim, tag findings `[build]`/`[test]`, do not fix anything.

**Checkpoint: `finder-results`**

Every launched agent returned inline with findings or evidence-bearing empty receipt.

**Gate**

- All substantive: **CONTINUE Step 3**.
- An agent returned bare "No issues found." with no walked-evidence, or returned near-instantly with almost no output: relaunch that ONE agent once with the whiff named; second bare return → take it and record its dimension as `unreviewed lens` in the matrix (caps any "clean" claim). **CONTINUE Step 3**.
- An agent failed/errored (tool crash, timeout): relaunch once; second failure → same `unreviewed lens` treatment. **CONTINUE Step 3**.

### 3. Cross-check into a consensus matrix

**Step**

Dedup the union: same defect + same location + same root cause keeps one entry at the highest severity, noting every lens that flagged it. Then rule each entry:

- **agree** — flagged by ≥2 lenses, OR flagged once with executed evidence (probe output, failing command, computed metric) from the finder.
- **rejected** — claim disproved by execution or direct counter-evidence (quote the decisive line/output). Rejected entries are reported, never fixed.
- **contested** — lenses conflict, OR a lens conflicts with the domain doc (e.g. "dead column" vs SDD listing it as planned surface). Record both sides + the doc citation.
- **held** — single lens, plausible, but evidence is read-only and a fix would change behavior (risky refactors). Hold with the evidence.

Probe anything runnable that decides agree-vs-rejected (run the code, compute the metric — restore the tree after, `git status` must be clean). Check every load-bearing new claim against the code before accepting it.

**Checkpoint: `consensus-matrix`**

Matrix with four sections, each entry carrying lenses-that-flagged, evidence, and (for contested) the doc citation.

**Gate**

- Every entry ruled: **CONTINUE Step 4**.
- A "fact" rests only on prose with no code check and matters for a fix decision: probe it now; **RETURN Step 3**.
- Two lenses produce genuinely different scopes (not duplicates): both stay as separate entries; **CONTINUE Step 4**.

### 4. Fix what everyone agrees on

**Step**

Apply agreed fixes only. One logical fix = one commit (`fix(scope): ...` conventional message) so record-each-step stays clean and any single fix is revertible. Skip nothing silently: a finding you decline to fix despite agreement gets outcome `skipped` + reason in the report.

**Checkpoint: `fix-log`**

Commit list (one per fix) + per-finding outcome (fixed / skipped+reason).

**Gate**

- Tree clean, every agreed finding has an outcome: **CONTINUE Step 5**.
- A "fix" would change public behavior/API beyond the finding's scenario (verb rename, format unification visible to users): reclassify as contested, ask via the report (or ask_user_question if mid-round); **RETURN Step 3**.
- A fix turns out wrong mid-edit (breaks a test, contradicts code reality): revert that edit, move finding to rejected/held with the counter-evidence; **RETURN Step 3**.
- No agreed fixes (all contested/rejected/held): **CONTINUE Step 5** (verification still runs on the untouched tree) — or skip to Step 6 if the tree is untouched and nothing ran.

### 5. Verify for real

**Step**

Run the full project verification: build per side, full unit suites, backend tests, and end-to-end tests when the round touched UI. Fresh fixture state for e2e (throwaway DB). Quote pass counts and any failure verbatim.

**Checkpoint: `verification-evidence`**

Command list + outcomes (pass counts / failure text).

**Gate**

- All green: **CONTINUE Step 6**.
- Red caused by a fix: fix the code, not the test — unless the test pinned deliberately-changed behavior (then update the test in its own commit, citing the behavior change). **RETURN Step 4**.
- Verification blocked (no commands, env failure): record `verification: blocked — <exact reason>`; **CONTINUE Step 6**. Never claim verified.

### 6. Report and hand off

**Step**

Deliver: the consensus matrix (agreed / rejected / contested / held — held section is the report's centerpiece), fix log with commit hashes, verification evidence, and for every held/contested item: evidence, both sides, 2-3 concrete options. Then wait — contested items are the user's call, not a follow-up task.

**Checkpoint: `cross-review-report`**

Report delivered; user can decide each held item from the report alone.

**Gate**

- Report complete, no unreviewed lens hidden: **COMPLETE**.
- Any `unreviewed lens` from Step 2: named explicitly in the report with its consequence (that dimension unverified) — still COMPLETE, but the cap is visible.
- User immediately wants held items fixed: re-enter Step 4 scoped to the items they approved, then Step 5.

## Failure modes baked into gates

- **Solo-lens inflation**: one lens demanding deletion of something the domain doc plans for = contested, not agreed. The doc wins until the user says otherwise.
- **Probe beats prose**: a claim killed by running code is dead regardless of how many lenses believed it; a claim surviving a probe is alive regardless of lens count.
- **Verification theater**: passing counts must come from commands actually run this round. A fix round without green evidence is not done.
- **Commit hygiene**: one fix per commit keeps `git revert` surgical and record-each-step's squash honest.
