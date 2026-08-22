---
name: record-each-step
description: >
  Auto-commit after every change on branch `agent-working`. Conventional
  commits, short messages. On "contribute"/"squash to main"/"merge my work",
  squash to main with a /caveman-commit message from the net diff, then reset
  agent-working. Auto-enables when project AGENTS.md/QWEN.md/CLAUDE.md marks
  it enabled; /record-each-step on|off toggles. Silently skips in non-git
  workspaces (notifies once).
---

# record-each-step

## Contract

**Must produce:** every change committed immediately on `agent-working`; clean
tree at every reportable milestone; on request, one squash commit on `main`
whose message describes the net diff, then `agent-working` reset to `main`.

**Must never do:** commit to or switch to another branch without explicit user
request; batch unrelated changes in one commit; push without explicit ask;
replay intermediate step commits in the squash message.

**Needs:** git repo, `/caveman-commit` for squash message.

**Done when:** tree clean, work on `agent-working`, contribution squashed and
reset verified.

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
On activation, resolve enablement — explicit toggle wins over project file:

- `/record-each-step off` → disabled.
- `/record-each-step on` → enabled (overrides project-file silence).
- Project instruction file (`AGENTS.md` / `QWEN.md` / `CLAUDE.md`) says
  "Enabled by default" or "enabled by default if the skill is installed"
  → enabled.
- None of the above → disabled.

CHECKPOINT `enable_state` — enabled or disabled, plus source.

GATE
- Disabled: **STOP** — no-op.
- Enabled, not a git workspace (no `.git`): notify once
  "record-each-step: not a git repository — skipping.", then **STOP**.
- Enabled, git workspace: **CONTINUE Step 2**.

### 2. Set up branch

**Step**
Inspect branch state:

| State | Action |
|---|---|
| On `agent-working` | Resume — continue where last session left off |
| `agent-working` exists, current is different (e.g. `main`) | Stale branch. Verify `git status` clean, then rename to `agent-working-1` (increment `-2`, `-3`... until free) and create fresh `agent-working` from current HEAD |
| No `agent-working` | Create fresh `agent-working` from current HEAD |

CHECKPOINT `branch_state` — on `agent-working`, created from current HEAD,
tree clean.

GATE
- On `agent-working`, clean: **CONTINUE Step 3**.
- Dirty tree at rename: commit or stash first, **RETURN Step 2**.
- Rename blocked: **STOP** with exact blocker.

### 3. Commit loop

**Step**
After every change, immediately: `git add <files>` + one conventional commit.
Unrelated changes get separate commits.

CHECKPOINT `commit_evidence` — `git status` clean; `git log -1` matches the
change.

GATE
- Tree clean: **CONTINUE Step 4**.
- Unrelated changes batched in one commit: split, **RETURN Step 3**.

### 4. Report

**Step**
Report only when the tree is clean. If the user asks to contribute/sync
("contribute", "squash to main", "merge my work"): **ENTER lane-contribute**.

CHECKPOINT `clean_report` — tree clean at milestone.

GATE
- Tree clean, task done: **COMPLETE**.
- Contribute requested: **ENTER lane-contribute**.

## Lane: contribute

### L1. Precondition

**Step**
Verify `git status` clean and `agent-working` diverged from `main`
(`git rev-parse agent-working main` differ).

CHECKPOINT `contribution_ready` — clean tree, branch diverged.

GATE
- Dirty: commit or ask first, **RETURN L1**.
- Not diverged (nothing to contribute): **STOP** — tell user.
- Ready: **CONTINUE L2**.

### L2. Squash

**Step**
```bash
git checkout main
git merge --squash agent-working
```
On conflict: resolve, then `git add` resolved files.

CHECKPOINT `staged_net_diff` — staged tree shows the net change
(`git diff --cached --stat`).

GATE
- Conflict resolved, staged tree coherent: **CONTINUE L3**.
- Conflict unresolvable: **STOP** with exact conflict files.
- Squash clean: **CONTINUE L3**.

### L3. Message and commit

**Step**
Run `/caveman-commit`. Write the message from `git diff --cached --stat` —
what the user sees, why — not a replay of step commits. Commit on `main`.

CHECKPOINT `squash_commit` — `git log main -1` shows the squash commit.

GATE
- Squash landed: **CONTINUE L4**.
- Commit failed: fix, **RETURN L3**.

### L4. Reset agent-working

**Step**
```bash
git checkout agent-working
git reset --hard main
```
If a permission guard blocks: state that the step-commit history is being
discarded (content is preserved in main's squash commit) and get explicit
approval.

CHECKPOINT `reset_evidence` — on `agent-working`, HEAD = main, tree clean.

GATE
- Reset verified: **CONTINUE L5**.
- Blocked: **STOP** — report; content is safe in main's squash commit.

### L5. Report

**Step**
Report squash commit hash, net changes. No push unless explicitly asked.

GATE
- Reported: **COMPLETE**.

## Exception lanes

- **Non-git workspace** — handled in Step 1 gate: notify once, skip.
- **Squash conflict** — handled inside L2: resolve, continue.
- **Permission-blocked reset** — handled in L4: stop with report; squash
  commit on main already preserves content.

## Output contract

- Every reportable milestone: `git status` clean.
- Contribution: exactly one squash commit on `main`; message = net diff;
  `agent-working` reset to `main` and verified.
- No push without explicit ask.

## Examples

```
feat(api): add rate limiter middleware
fix(auth): handle null token in verify()
docs(readme): update install instructions
chore(deps): bump lodash to 4.17.21
```
