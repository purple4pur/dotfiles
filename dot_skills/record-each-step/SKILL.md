---
name: record-each-step
description: >
  Auto-commit every change on `agent-working`, or on an explicitly requested
  existing branch. Conventional commits, short messages. On "contribute",
  "squash to main", or "merge my work", squash the managed branch to main
  as one or more meaningful, healthy milestone commits with approximate
  original author dates and /caveman-commit messages, then reset it.
  Enable with /record-each-step, /record-each-step on, or
  enable /record-each-step. Disable with /record-each-step off or
  disable /record-each-step. Skip non-Git workspaces with one notice.
---

# record-each-step

## Contract

**Must produce:** every change committed immediately on the managed branch;
clean tree at every reportable milestone. On request, produce one or more
milestone commits on `main`, then reset the managed branch to `main`.
Each milestone must preserve its net change, pass relevant checks, and use
an approximate original author date.

**Must never do:** create or rename a branch when the user explicitly requested
one; switch to a branch other than the requested branch; use a requested branch
that does not exist; batch unrelated changes in one commit; push without
explicit ask; replay intermediate step commits in milestone messages.

**Needs:** git repo, source commit metadata, `/caveman-commit` for milestone messages.

**Done when:** tree clean, work on the managed branch, contribution squashed
and reset verified.

## Core rules

- Commit each logical change immediately, including edits, additions, deletions, and refactors. Keep unrelated changes in separate commits.
- Conventional commits: `<type>(<scope>): <imperative summary>`.
  Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `perf`, `test`, `style`,
  `build`, `ci`. Subject ≤72 chars. Use a body only when the reason is not clear
  from the diff.
- No dirty state at milestones.

## Main line

Resolve active state → select branch → commit each change → report or contribute.

### 1. Qualify enablement

**Step**

Resolve enablement from an explicit user invocation. Match the complete
command form below; quoted examples and mentions are not invocations.
Evaluate disable forms first:

- `/record-each-step off` or `disable /record-each-step` → disabled.
- `/record-each-step`, `/record-each-step on`, or
  `enable /record-each-step` → enabled.
- `/record-each-step on <branch>` → enabled and requests that existing branch.
- An explicitly invoked workflow requires `record-each-step` → enabled; record that caller.
- No new enable or disable command → preserve the active state for this session. Default to disabled in a new session.
- A mention, quotation, or file edit alone never enables the skill.

**Checkpoint: `enable_state`**

Enabled or disabled, trigger source, and any explicit requested branch. Retain this state across session turns.

**Gate**

- Disabled: **STOP** — no-op.
- Enabled, not a Git workspace (`git rev-parse --is-inside-work-tree` fails): notify once
  "record-each-step: not a git repository — skipping.", then **STOP**.
- Enabled, git workspace: **CONTINUE Step 2**.

### 2. Resolve the managed branch

**Step**

Record `requested_branch` only when the user explicitly names a branch, for
example `/record-each-step on feature/fix`. Otherwise set it empty. Verify
`git status` is clean before any branch operation.

If `requested_branch` is set:

1. Verify `refs/heads/<requested_branch>` exists.
2. Switch to it if needed, set `managed_branch` to it, and continue. Do not
   create, rename, or select another branch.

Otherwise manage `agent-working`:

| State | Action |
|---|---|
| Current branch is `agent-working` | Set `managed_branch=agent-working`; resume. |
| `agent-working` exists and current HEAD is an ancestor of its tip | It is the latest managed branch for the active line. Switch to it; set `managed_branch=agent-working`. |
| `agent-working` exists but does not contain current HEAD | It is old. Rename it to `agent-working-N`, where `N` is one greater than the largest existing numeric `agent-working-N` suffix; create `agent-working` from current HEAD; set `managed_branch=agent-working`. |
| `agent-working` does not exist | Create it from current HEAD; set `managed_branch=agent-working`. |

`agent-working` is **active** only when it is the current branch. It is
**latest** only when `git merge-base --is-ancestor <current-HEAD>
agent-working` succeeds. Do not infer freshness from commit timestamps or
branch names.

**Checkpoint: `branch_state`**

`requested_branch`, `managed_branch`, original branch, branch-existence proof,
and topology proof when `agent-working` already existed; worktree clean.

**Gate**

- Requested branch absent: **STOP** — report its exact name; do not create it.
- Worktree dirty: preserve user changes. Use an already authorized preservation plan, then **RETURN Step 2**.
  If no safe plan exists, **STOP** with the affected paths. Do not commit or stash unrelated user changes.
- Managed branch selected and worktree clean: **CONTINUE Step 3**.
- Rename, create, or switch blocked: **STOP** with exact blocker.

### 3. Commit loop

**Step**

After each logical change, stage explicit owned paths and create one Conventional Commit.
Keep unrelated changes separate. Check the staged diff before the commit.
Commit only the task changes. Keep existing user changes outside the commit.

**Checkpoint: `commit_evidence`**

`git status` clean; `git log -1` matches the change.

**Gate**

- Tree clean: **CONTINUE Step 4**.
- Staged diff includes unrelated changes: unstage those paths; **RETURN Step 3** before the commit.
- Commit or required check fails: repair the cause; **RETURN Step 3**.
- Repair needs unavailable authority or input: **STOP** with the exact blocker.
- Existing commit contains unrelated changes: **STOP** for a history-repair decision. Preserve the commit.

### 4. Report

**Step**

Check output against the STE rules below. Report only when the tree is clean.
For an incomplete contribution request, **ENTER lane-contribute**.
Use "contribute", "squash to main", or "merge my work" as contribution requests.

**Checkpoint: `clean_report`**

Tree clean at milestone.

**Gate**

- Contribution requested and not complete: **ENTER lane-contribute**.
- Tree clean, task done: **COMPLETE**.
- More authorized work remains: **RETURN Step 3**.
- Tree dirty: **RETURN Step 3** for task changes; **STOP** if user changes prevent a clean milestone.

## Lane: contribute

### L1. Verify readiness

**Step**

Verify the tree is clean and both branches exist. Keep `managed_branch` distinct from `main`.
Record both tips. Inspect topology and the net change before the squash.
Use `git log main..<managed_branch>` to prove that managed commits remain outside `main`.
A different tip alone does not prove there is work to contribute.
Record source hashes, author dates, and subjects before any contribution commit:

```bash
git log --reverse --topo-order --format='%H %aI %s' main..<managed_branch>
```
Inspect source diffs to identify which commits supply the surviving changes.
Use topology to order dependencies. Author dates do not prove dependency order.

**Checkpoint: `contribution_ready`**

Clean tree, distinct existing branches, recorded tips, topology, source metadata,
and a non-empty net contribution.

**Gate**

- Dirty task changes: **RETURN Step 3**. Dirty user changes: **STOP** and preserve them.
- A branch is absent, or `managed_branch` is `main`: **STOP** with the exact branch problem.
- No managed commits remain outside `main`, or the net contribution is empty: **STOP** with no-work status.
- Ready: **CONTINUE L2**.

### L2. Resolve the complete contribution

**Step**

```bash
git checkout main
git merge --squash <managed_branch>
```
On conflict: resolve, then `git add` resolved files.

**Checkpoint: `staged_net_diff`**

Record `git diff --cached` and its stat, the staged tree ID, and the unchanged managed tip.
The staged diff contains the complete resolved contribution.

**Gate**

- Conflict resolved, staged tree coherent and non-empty: **CONTINUE L3**.
- Conflict unresolvable: **STOP** with exact conflict files.
- Squash clean and staged diff non-empty: **CONTINUE L3**.
- Squash fails for another reason: **STOP** with the exact error.
- Staged diff empty: **STOP** with no-work status.

### L3. Plan milestones and author dates

**Step**

Use one commit for a cohesive outcome. Use multiple commits for distinct milestones that remain useful on their own.
Keep each milestone reviewable and complete. Include its required tests, documentation, and dependencies.
Combine coupled changes when a split would leave broken behavior or failed checks.

Group by the surviving contribution. Omit temporary edits, later reversals, and repairs already absorbed into the final result.

Build an ordered plan from the recorded `main` tip to L2's staged tree.
Map each milestone to its source hashes, net change, cumulative tree ID, and relevant checks.
Every cumulative tree includes the preceding milestones. The last tree must equal L2's staged tree.
On a return from L4, preserve the completed prefix. Replan only the remaining milestones from the verified current `main` tip.

Choose each milestone's author date from the original commit that best represents its completion.
Usually use the last source commit that supplies surviving changes to that milestone, in dependency order.
Keep its `%aI` timestamp and timezone offset. Keep the committer date at the current time.
Do not force author dates into chronological order when source dates differ from dependency order.

If the preferred date is unavailable, use another attributable source date.
If no source date is available, use the current author date and record that fallback.

**Checkpoint: `milestone_plan`**

Ordered milestones with source hashes, cumulative tree IDs, required checks,
chosen author dates, date-selection reasons, and any metadata fallback.
The planned changes cover the complete resolved contribution exactly once.

**Gate**

- Plan complete, trees available, final tree matches L2: **CONTINUE L4**.
- Split leaves incomplete behavior or omits a change: regroup; **RETURN L3**.
- Date evidence missing: apply the recorded fallback; **RETURN L3**.
- Tree construction fails: **STOP** with the exact blocker. Preserve both recorded branch tips.

### L4. Validate and commit milestones

**Step**

Verify `main` still matches L1's tip before the first commit.
Before each later commit, verify `main` matches the last recorded milestone hash.
Verify the managed tip still matches L1 before each commit.

Process the plan in dependency order. Validate each cumulative tree in an isolated, detached temporary worktree.
Exclude later milestone changes from that worktree. Run repository-required checks and checks relevant to the milestone.
Record the tree ID and results. Repair a failed split through L3 before any affected commit.

For each validated milestone, stage its planned tree without changing the resolved working files:

```bash
git read-tree <milestone_tree>
git diff --cached
git diff --cached --stat
```

Verify the staged tree matches the validated tree and the diff matches the planned milestone.
Require a non-empty staged diff for every milestone.
Run `/caveman-commit` for that staged diff. Describe the milestone's outcome and reason.
Commit on `main` with the selected author date:

```bash
git commit --date="$milestone_author_date" -m "$milestone_message"
```

Verify each new commit's parent, tree, and `%aI` author date before the next commit.
Keep later task changes outside that commit. Report only after the final tree is clean.

**Checkpoint: `milestone_commits`**

Record each milestone hash, parent, tree ID, author date, message, and check results.
The new commits form the planned linear chain from L1's `main` tip.
The final tree matches L2's staged tree. The managed tip still matches L1.
The worktree is clean. Keep the final hash and both preservation IDs for reset verification.

**Gate**

- All milestones landed and preservation evidence matches: **CONTINUE L5**.
- A remaining milestone is empty or fails checks or staging verification: **RETURN L3** for the remaining plan.
- Commit fails without changing HEAD: repair the cause; **RETURN L4** at that milestone.
- An existing milestone, branch tip, or final tree differs from the evidence: **STOP** before reset with the exact mismatch.
- A required check cannot run: **STOP** with the validation limit. Preserve the managed branch.

### L5. Reset the managed branch

**Step**

Before reset, verify a clean tree, the recorded managed tip, and the final milestone commit tree.
Confirm that the milestone commits preserve the complete resolved contribution.

```bash
git checkout <managed_branch>
git reset --hard main
```
If a permission guard blocks: state that the step-commit history is being
discarded (content is preserved in main's milestone commits) and get explicit
approval.

**Checkpoint: `reset_evidence`**

On `managed_branch`, HEAD = main, tree clean.

**Gate**

- Reset verified: **CONTINUE L6**.
- Tip changed or preservation check fails: **STOP** before reset. Report the exact mismatch.
- Blocked: **STOP** — report the milestone commits and reset limit.

### L6. Report

**Step**

Check the output against the STE rules below.
Report milestone hashes, net changes, author dates, date-selection reasons, check results, reset evidence, and validation limits.
Disclose any author-date fallback.
Push only when the user explicitly requests it.

**Checkpoint: `contribution_report`**

The user can locate each milestone commit and inspect its date, checks, and the verified branch state.

**Gate**

- Report complete: **RETURN Step 4** with contribution complete.
- Report lacks evidence: **RETURN L6**.

## Exception lanes

- **Requested branch absent** — handled in Step 2 gate: stop; do not create or
  rename any branch.
- **Non-git workspace** — handled in Step 1 gate: notify once, skip.
- **Squash conflict** — handled inside L2: resolve, continue.
- **Permission-blocked reset** — handled in L5: stop with report; milestone
  commits on main already preserve content.

## Output contract

- Every reportable milestone: `git status` clean.
- Contribution: one or more meaningful, healthy milestone commits on `main`.
  Each message describes its milestone's net diff. Each author date follows L3's source-date rule.
  The final tree preserves L2's resolved contribution. `managed_branch` is reset to `main` and verified.
- No push without explicit ask.

## Examples

```
feat(api): add rate limiter middleware
fix(auth): handle null token in verify()
docs(readme): update install instructions
chore(deps): bump lodash to 4.17.21
```

## Output language and validation

Read [STE rules](../write-docs/references/ste.md) before you write English prose.
This shared reference belongs to the local skill bundle. It does not invoke the `write-docs` workflow.
Use concise, grammatical sentences in status updates, explanations, and the final report.
Keep the user's requested language. Preserve exact evidence, technical terms, paths, commands, code, and required formats.
Keep native commit syntax. Apply STE to explanatory comments where source conventions permit it.
STE takes precedence over caveman fragments within the remaining style choices.
Before each delivery, check sentence length, articles, voice, stable terms, conditions, and negations.
If prose fails the check, revise it before delivery. Report material validation limits. Claim only checks that ran.
