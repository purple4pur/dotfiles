---
name: record-each-step
description: >
  Auto-commit after every change. Creates branch `agent-working` on clone if
  missing. All work stays on `agent-working` unless user explicitly says
  otherwise. Conventional commits, short messages. Disabled by default —
  enable explicitly with "/record-each-step on". Silently skips in non-git
  workspaces (notices user once on first invocation).
---

# record-each-step

## Core rules

1. **Branch discipline.** Work ONLY on branch `agent-working`. Never commit to or switch to another branch without explicit user request. If `agent-working` doesn't exist on clone, create it from the current state and base all work there.

2. **Commit after EVERY change.** Any modification to any code or document in this project — edit, create, delete, refactor — must be committed immediately. No batching of unrelated changes in one commit.

3. **No dirty state.** When a task finishes, if there are pending uncommitted changes, commit them before reporting done. The working tree must be clean at every reportable milestone.

4. **Conventional commits.** Short, descriptive messages. Format: `<type>(<scope>): <imperative summary>`. Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `perf`, `test`, `style`, `build`, `ci`. Subject ≤72 chars. Body only when the *why* isn't obvious from the diff.

## Disabled by default

This skill is OFF on load. Enable with: `/record-each-step on`
Disable with: `/record-each-step off`

When disabled, do nothing — no branch checks, no commit enforcement.

## Non-git workspace

If the current working directory is not a git repository (no `.git` directory), skip all enforcement silently. At the first invocation (first time the skill is activated in a non-git workspace), notify the user once: "record-each-step: not a git repository — skipping."

## Examples

```
feat(api): add rate limiter middleware
fix(auth): handle null token in verify()
docs(readme): update install instructions
chore(deps): bump lodash to 4.17.21
```
