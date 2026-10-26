---
name: record-each-step
description: >
  Auto-commit every change on `agent-working`, or on an explicitly requested
  existing branch. Conventional commits, short messages. On "contribute",
  "squash to main", or "merge my work", squash the managed branch to main
  with a /caveman-commit message from the net diff, then reset it.
  Enable with /record-each-step, /record-each-step on, or
  enable /record-each-step. Disable with /record-each-step off or
  disable /record-each-step. Skip non-Git workspaces with one notice.
---

# record-each-step

## Contract

**Must produce:** every change committed immediately on the managed branch;
clean tree at every reportable milestone; on request, one squash commit on
`main` whose message describes the net diff, then the managed branch reset to
`main`.

**Must never do:** create or rename a branch when the user explicitly requested
one; switch to a branch other than the requested branch; use a requested branch
that does not exist; batch unrelated changes in one commit; push without
explicit ask; replay intermediate step commits in the squash message.

**Needs:** git repo, `/caveman-commit` for squash message.

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

**Checkpoint: `contribution_ready`**

Clean tree, distinct existing branches, recorded tips, topology, and a non-empty net contribution.

**Gate**

- Dirty task changes: **RETURN Step 3**. Dirty user changes: **STOP** and preserve them.
- A branch is absent, or `managed_branch` is `main`: **STOP** with the exact branch problem.
- No managed commits remain outside `main`, or the net contribution is empty: **STOP** with no-work status.
- Ready: **CONTINUE L2**.

### L2. Squash

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

- Conflict resolved, staged tree coherent: **CONTINUE L3**.
- Conflict unresolvable: **STOP** with exact conflict files.
- Squash clean and staged diff non-empty: **CONTINUE L3**.
- Squash fails for another reason: **STOP** with the exact error.
- Staged diff empty: **STOP** with no-work status.

### L3. Message and commit

**Step**

Run `/caveman-commit`. Write the message from `git diff --cached` and its stat —
what the user sees, why — not a replay of step commits. Commit on `main`.

**Checkpoint: `squash_commit`**

`git log main -1` shows the squash commit. Its tree ID matches the recorded staged tree.
The managed tip still matches L1. Keep both IDs for reset verification.

**Gate**

- Squash landed and preservation evidence matches: **CONTINUE L4**.
- Squash tree or managed tip differs from the recorded evidence: **STOP** before reset with the exact mismatch.
- Commit failed: fix, **RETURN L3**.

### L4. Reset the managed branch

**Step**

Before reset, verify a clean tree, the recorded managed tip, and the squash commit tree.
Confirm that the squash preserves the resolved contribution.

```bash
git checkout <managed_branch>
git reset --hard main
```
If a permission guard blocks: state that the step-commit history is being
discarded (content is preserved in main's squash commit) and get explicit
approval.

**Checkpoint: `reset_evidence`**

On `managed_branch`, HEAD = main, tree clean.

**Gate**

- Reset verified: **CONTINUE L5**.
- Tip changed or preservation check fails: **STOP** before reset. Report the exact mismatch.
- Blocked: **STOP** — report the squash commit and reset limit.

### L5. Report

**Step**

Check the output against the STE rules below. Report the squash hash, net changes, reset evidence, and validation limits.
Push only when the user explicitly requests it.

**Checkpoint: `contribution_report`**

The user can locate the squash and inspect the verified branch state.

**Gate**

- Report complete: **RETURN Step 4** with contribution complete.
- Report lacks evidence: **RETURN L5**.

## Exception lanes

- **Requested branch absent** — handled in Step 2 gate: stop; do not create or
  rename any branch.
- **Non-git workspace** — handled in Step 1 gate: notify once, skip.
- **Squash conflict** — handled inside L2: resolve, continue.
- **Permission-blocked reset** — handled in L4: stop with report; squash
  commit on main already preserves content.

## Output contract

- Every reportable milestone: `git status` clean.
- Contribution: exactly one squash commit on `main`; message = net diff;
  `managed_branch` reset to `main` and verified.
- No push without explicit ask.

## Examples

```
feat(api): add rate limiter middleware
fix(auth): handle null token in verify()
docs(readme): update install instructions
chore(deps): bump lodash to 4.17.21
```

## Output language and validation

Read [STE rules](../stronger-skill/references/ste.md) before you write English prose.
This shared reference belongs to the local skill bundle. It does not invoke the `stronger-skill` workflow.
Use concise, grammatical sentences in status updates, explanations, and the final report.
Keep the user's requested language. Preserve exact evidence, technical terms, paths, commands, code, and required formats.
Keep native commit syntax. Apply STE to explanatory comments where source conventions permit it.
STE takes precedence over caveman fragments within the remaining style choices.
Before each delivery, check sentence length, articles, voice, stable terms, conditions, and negations.
If prose fails the check, revise it before delivery. Report material validation limits. Claim only checks that ran.
