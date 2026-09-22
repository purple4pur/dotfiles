---
name: record-each-step
description: >
  Auto-commit every change on `agent-working`, or on an explicitly requested
  existing branch. Conventional commits, short messages. On "contribute",
  "squash to main", or "merge my work", squash the managed branch to main
  with a /caveman-commit message from the net diff, then reset it.
  /record-each-step on|off toggles. Silently skips in non-git workspaces
  (notifies once).
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

- Commit after EVERY change — edit, create, delete, refactor. No batching.
- Conventional commits: `<type>(<scope>): <imperative summary>`.
  Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `perf`, `test`, `style`,
  `build`, `ci`. Subject ≤72 chars. Body only when the *why* isn't obvious
  from the diff.
- No dirty state at milestones.

## Main line

### 1. Qualify enablement

**Step**

On activation, resolve enablement:

- `/record-each-step off` → disabled.
- `/record-each-step on` → enabled.
- `/record-each-step on <branch>` → enabled and requests that existing branch.
- None of the above → disabled.

**Checkpoint: `enable_state`**

Enabled or disabled, plus trigger source.

**Gate**

- Disabled: **STOP** — no-op.
- Enabled, not a git workspace (no `.git`): notify once
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
- Worktree dirty: commit or stash first, **RETURN Step 2**.
- Managed branch selected and worktree clean: **CONTINUE Step 3**.
- Rename, create, or switch blocked: **STOP** with exact blocker.

### 3. Commit loop

**Step**

After every change, immediately: `git add <files>` + one conventional commit.
Unrelated changes get separate commits.

**Checkpoint: `commit_evidence`**

`git status` clean; `git log -1` matches the change.

**Gate**

- Tree clean: **CONTINUE Step 4**.
- Unrelated changes batched in one commit: split, **RETURN Step 3**.

### 4. Report

**Step**

Report only when the tree is clean. If the user asks to contribute/sync
("contribute", "squash to main", "merge my work"): **ENTER lane-contribute**.

**Checkpoint: `clean_report`**

Tree clean at milestone.

**Gate**

- Tree clean, task done: **COMPLETE**.
- Contribute requested: **ENTER lane-contribute**.

## Lane: contribute

### L1. Verify readiness

**Step**

Verify `git status` clean and `managed_branch` diverged from `main`
(`git rev-parse <managed_branch> main` differ).

**Checkpoint: `contribution_ready`**

Clean tree; `managed_branch` diverged from `main`.

**Gate**

- Dirty: commit or ask first, **RETURN L1**.
- Not diverged (nothing to contribute): **STOP** — tell user.
- Ready: **CONTINUE L2**.

### L2. Squash

**Step**

```bash
git checkout main
git merge --squash <managed_branch>
```
On conflict: resolve, then `git add` resolved files.

**Checkpoint: `staged_net_diff`**

Staged tree shows the net change (`git diff --cached --stat`).

**Gate**

- Conflict resolved, staged tree coherent: **CONTINUE L3**.
- Conflict unresolvable: **STOP** with exact conflict files.
- Squash clean: **CONTINUE L3**.

### L3. Message and commit

**Step**

Run `/caveman-commit`. Write the message from `git diff --cached --stat` —
what the user sees, why — not a replay of step commits. Commit on `main`.

**Checkpoint: `squash_commit`**

`git log main -1` shows the squash commit.

**Gate**

- Squash landed: **CONTINUE L4**.
- Commit failed: fix, **RETURN L3**.

### L4. Reset the managed branch

**Step**

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
- Blocked: **STOP** — report; content is safe in main's squash commit.

### L5. Report

**Step**

Report squash commit hash, net changes. No push unless explicitly asked.

**Gate**

- Reported: **COMPLETE**.

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
