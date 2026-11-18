---
name: record-each-step
description: >
  Auto-commit each logical change on agent-working or an explicitly requested
  existing branch. Enable with /record-each-step, /record-each-step on,
  enable /record-each-step, or /record-each-step on BRANCH. Disable with
  /record-each-step off or disable /record-each-step. While enabled, use
  contribute, squash to main, or merge my work to squash the managed work
  into healthy milestones on main, preserve approximate author dates, and
  reset the managed branch. Skip non-Git workspaces with one notice.
---

# Record each step

Commit each logical task change immediately. Keep the tree clean at reportable milestones.

## Rules

- Enable only through a complete user command or an explicitly invoked workflow that requires this skill.
  Mentions, quotations, examples, and edits to this skill do not enable it.
- Preserve the active state across session turns. A new session starts disabled.
- Stage explicit task paths and inspect the staged diff. Preserve unrelated user changes outside commits.
- Use one Conventional Commit per logical change, including additions, deletions, edits, and refactors.
- Push only when the user explicitly requests it.

Use `<type>(<scope>): <imperative summary>` with a subject of at most 72 characters.
Use these types: `feat`, `fix`, `docs`, `chore`, `refactor`, `perf`, `test`, `style`, `build`, and `ci`.
Add a body only when the diff does not explain the reason.

## Workflow

Resolve active state → select branch → commit each change → report or contribute.

### 1. Resolve enablement

**Step:** Evaluate disable commands first, then enable commands:

- `/record-each-step off` or `disable /record-each-step`: disable.
- `/record-each-step`, `/record-each-step on`, or `enable /record-each-step`: enable.
- `/record-each-step on <branch>`: enable on that existing branch.
- Explicitly invoked workflow requires this skill: enable and record the caller.
- No new command: retain the session state.

**Checkpoint: `enable_state`** — Active state, trigger source, and any requested branch.

**Gate:** Disabled: **STOP** without action.
Enabled and `git rev-parse --is-inside-work-tree` succeeds: **CONTINUE Step 2**.
Non-Git workspace: notify once, then **STOP**:

```text
record-each-step: not a git repository — skipping.
```

### 2. Select the managed branch

**Step:** Record the original branch and verify a clean tree before any branch operation.
If the user requests a branch, verify `refs/heads/<requested_branch>` exists and switch to that branch only.
Keep its name. Never create a missing requested branch or select a substitute.

Without a requested branch, manage `agent-working`:

| State | Action |
|---|---|
| Current branch is `agent-working` | Resume it. |
| Branch exists and contains current HEAD | Switch to it. |
| Branch exists but does not contain current HEAD | Rename it to `agent-working-N`, then create `agent-working` from current HEAD. |
| Branch does not exist | Create it from current HEAD. |

Set `N` one above the largest existing numeric suffix.
Prove containment with `git merge-base --is-ancestor <current-HEAD> agent-working`.
The current branch is active. Containment proves the latest managed line. Names and timestamps do not prove freshness.

**Checkpoint: `branch_state`** — Requested and managed names, original branch, existence and topology evidence, and clean tree.

**Gate:** Managed branch selected: **CONTINUE Step 3**.
Requested branch missing or branch operation blocked: **STOP** with the exact problem.
Dirty tree: preserve user changes with an already authorized plan, then **RETURN Step 2**.
No safe preservation plan: **STOP** with affected paths. Keep unrelated changes uncommitted and unstashed.

### 3. Commit each logical change

**Step:** Complete the change and required checks. Stage its explicit owned paths.
Inspect the staged diff, exclude unrelated changes, and create one Conventional Commit.

**Checkpoint: `commit_evidence`** — The tree is clean, and `git log -1` matches the logical change.

**Gate:** Evidence complete: **CONTINUE Step 4**.
Unrelated staged changes: unstage them and **RETURN Step 3** before the commit.
Commit or check fails: repair the cause and **RETURN Step 3**.
Repair needs missing authority or input: **STOP** with the blocker.
Committed changes include unrelated work: **STOP** for a history-repair decision. Preserve that commit.

### 4. Report or contribute

**Step:** Verify a clean tree and apply the output rules below.
For an unfinished contribution request, read [contribution.md](references/contribution.md) and follow L1 through L6.
Otherwise, report the task commits and completed checks.

**Checkpoint: `clean_report`** — The milestone is clean, and any requested contribution has verified preservation and reset evidence.

**Gate:** Contribution requested and unfinished: **ENTER L1 in contribution.md**.
Task and requested contribution complete: **COMPLETE**.
More authorized work remains: **RETURN Step 3**.
Dirty task changes: **RETURN Step 3**. Dirty user changes prevent a clean milestone: **STOP** and preserve them.

## Output rules

Read [STE rules](../write-docs/references/ste.md) for English prose. This reference does not invoke the `write-docs` workflow.
Keep the user's language, exact evidence, technical terms, and native commit syntax.
STE takes precedence over caveman fragments. Check prose before delivery and revise failures.
Report only completed checks. Name material limits.
