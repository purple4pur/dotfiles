---
name: record-each-step
description: >
  Auto-commit after every change. Creates branch `agent-working` on clone if
  missing. All work stays on `agent-working` unless user explicitly says
  otherwise. Conventional commits, short messages. On request, squash-
  contributes to main with a /caveman-commit message detailing the feature
  changes, then resets agent-working. Auto-enables when a project AGENTS.md
  or equivalent instruction marks it as enabled. Silently skips in non-git
  workspaces (notices user once on first invocation).
---

# record-each-step

## Core rules

1. **Branch discipline.** Work ONLY on branch `agent-working`. Never commit to
   or switch to another branch without explicit user request.

2. **Commit after EVERY change.** Any modification to any code or document in
   this project — edit, create, delete, refactor — must be committed
   immediately. No batching of unrelated changes in one commit.

3. **No dirty state.** When a task finishes, if there are pending uncommitted
   changes, commit them before reporting done. The working tree must be clean
   at every reportable milestone.

4. **Conventional commits.** Short, descriptive messages.
   Format: `<type>(<scope>): <imperative summary>`.
   Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `perf`, `test`, `style`,
   `build`, `ci`. Subject ≤72 chars. Body only when the *why* isn't obvious
   from the diff.

## Contribution workflow

When the user asks to contribute/sync `agent-working` to `main` (or says
"contribute", "squash to main", "merge my work"), do:

1. **Squash merge** — one commit on main for the whole contribution, not the
   step commits:
   ```bash
   git checkout main
   git merge --squash agent-working
   ```
2. **Commit message via `/caveman-commit`** — compact Conventional Commits
   message that **details the net feature changes**: subject
   `<type>(<scope>): <imperative summary>` ≤50 chars, body listing what the
   user sees/changes (what + why), not a replay of the intermediate step
   commits. Squash swallows delete/revert pairs — describe the net diff
   (`git diff main --stat` on the staged tree shows it).
3. **No push** unless the user explicitly asks.
4. **Reset agent branch after contribution**:
   ```bash
   git checkout agent-working
   git reset --hard main
   ```
   So the next work starts from main HEAD. This discards the step-commit
   history on `agent-working` (content is preserved in main's squash commit).
   `git reset --hard` may trip permission guards — state that local work is
   being discarded and get explicit approval if blocked.

## Auto-enable

Enabled by default IF a project instruction file says so. The skill checks
two sources at load time — in priority order:

- **Project instruction file** (`AGENTS.md` / `QWEN.md` / `CLAUDE.md`):
  if it says "Enabled by default" or "enabled by default if the skill is
  installed", auto-enable.
- **User's `/record-each-step on` command**: explicit toggle, takes priority.

Manual toggles still work:
- `/record-each-step on`  — force enable (overrides AGENTS.md silence)
- `/record-each-step off` — force disable

## Existing agent-working branch handling

When enabling, check for an existing `agent-working` branch:

| Scenario | Action |
|---|---|
| `agent-working` exists AND is the current branch | Continue on it — resume where last session left off |
| `agent-working` exists BUT current branch is different (e.g. `main`) | The existing `agent-working` is stale. Rename it to `agent-working-1` (or `-2`, `-3`... increment until free). Then create fresh `agent-working` from current HEAD |
| `agent-working` does NOT exist | Create fresh `agent-working` from current HEAD |

Renaming rule: check `agent-working-1`, `agent-working-2`, etc. and pick the
first unused number.

## Non-git workspace

If the current working directory is not a git repository (no `.git` directory),
skip all enforcement silently. At the first invocation (first time the skill is
activated in a non-git workspace), notify the user once:
"record-each-step: not a git repository — skipping."

## Examples

```
feat(api): add rate limiter middleware
fix(auth): handle null token in verify()
docs(readme): update install instructions
chore(deps): bump lodash to 4.17.21
```
