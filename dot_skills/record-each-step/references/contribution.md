# Contribute managed work to main

Use this procedure only for a contribution request while `record-each-step` is enabled.
Produce healthy milestone commits, preserve the complete resolved contribution, then reset the managed branch.
Return to main workflow Step 4 after the report.

## L1. Verify readiness

**Step:** Require a clean tree and existing, distinct `main` and managed branches.
Record both tips and inspect topology, managed commits outside `main`, and the net contribution.
Capture source hashes, author dates, and subjects before any contribution commit:

```bash
git log --reverse --topo-order --format='%H %aI %s' main..<managed_branch>
```

Inspect source diffs to identify surviving changes. Order dependencies by topology, not author dates.
A different tip alone does not prove a contribution exists.

**Checkpoint: `contribution_ready`** — Clean tree, distinct branches, recorded tips, topology, source metadata, and non-empty net contribution.

**Gate:** Ready: **CONTINUE L2**.
Dirty task changes: **RETURN Step 3**. Dirty user changes: **STOP** and preserve them.
Missing branch, managed branch equals `main`, no managed commits outside `main`, or empty net change: **STOP** with the exact status.

## L2. Resolve the complete contribution

**Step:** After readiness passes, switch to `main` and squash the managed work:

```bash
git checkout main
git merge --squash <managed_branch>
```

Resolve scoped conflicts and stage resolved files.

**Checkpoint: `staged_net_diff`** — Complete resolved staged diff, its stat and tree ID, and unchanged managed tip.

**Gate:** Coherent non-empty staged tree: **CONTINUE L3**.
Empty diff: **STOP** with no-work status.
Unresolved conflicts or other squash failure: **STOP** with exact files or error.

## L3. Plan milestones and author dates

**Step:** Use one commit for a cohesive outcome. Split distinct outcomes only when each remains useful and passes checks independently.
Include required tests, documentation, and dependencies. Combine coupled changes that would fail when separated.
Group surviving changes. Omit temporary edits, reversals, and absorbed repairs from milestone messages.

Map each milestone to source hashes, net change, cumulative tree ID, and required checks.
Cover the resolved contribution exactly once. The last cumulative tree must equal L2's tree.
After a return from L4, preserve completed milestones and replan only the remaining work from verified current `main`.

Choose the source author date that best represents the milestone's completion.
Usually use the last dependency-ordered source commit that supplies surviving changes.
Preserve its `%aI` timestamp and timezone offset. Keep the committer date current.
Keep dependency order even when author dates differ from chronological order.
If the preferred date is missing, use another attributable source date.
If none exists, use the current author date and disclose the fallback.

**Checkpoint: `milestone_plan`** — Ordered trees, source hashes, checks, author dates, selection reasons, and metadata fallbacks.
The final tree matches L2, and all planned trees are available.

**Gate:** Plan complete: **CONTINUE L4**.
Incomplete split or omitted change: regroup and **RETURN L3**.
Missing date evidence: record the fallback and **RETURN L3**.
Tree construction blocked: **STOP** with the cause. Preserve both original tips.

## L4. Validate and commit milestones

**Step:** Before each commit, verify both branch tips against the recorded evidence.
For the first commit, `main` must match L1. Later commits must start at the last verified milestone hash.
The managed tip must still match L1.

Validate each cumulative tree in an isolated detached temporary worktree, without later milestone changes.
Run repository-required checks and relevant milestone checks. Record the tree ID and results.
Return failed splits to L3 before committing them.

Stage each validated tree without changing the resolved working files:

```bash
git read-tree <milestone_tree>
git diff --cached
git diff --cached --stat
```

Require a non-empty diff that matches the plan and the validated tree.
Use `/caveman-commit` for the staged milestone's outcome and reason.
Commit with the chosen author date:

```bash
git commit --date="$milestone_author_date" -m "$milestone_message"
```

Verify the new parent, tree, and `%aI` before the next commit. Keep later changes outside that commit.

**Checkpoint: `milestone_commits`** — Hashes, parents, trees, author dates, messages, and check results form the planned linear chain.
The final tree equals L2. The managed tip equals L1. The tree is clean.
Keep the original managed tip and resolved tree ID for reset verification.

**Gate:** All preservation evidence matches: **CONTINUE L5**.
Remaining milestone empty or fails checks or staging: **RETURN L3** for the remaining plan.
Commit fails with unchanged HEAD: repair and **RETURN L4** at that milestone.
Existing milestone, tip, or final tree differs: **STOP** before reset with the mismatch.
Required check cannot run: **STOP** with the validation limit and preserve the managed branch.

## L5. Reset the managed branch

**Step:** Require a clean tree, unchanged managed tip, and verified final milestone tree before reset.
Confirm the milestones preserve the complete resolved contribution.

```bash
git checkout <managed_branch>
git reset --hard main
```

If a permission guard blocks reset, explain that reset discards step-commit history.
State that `main` preserves the content, then obtain the required approval.

**Checkpoint: `reset_evidence`** — Current branch is the managed branch, HEAD equals `main`, and the tree is clean.

**Gate:** Reset verified: **CONTINUE L6**.
Tip changed or preservation failed: **STOP** before reset with the mismatch.
Reset blocked: **STOP** with milestone hashes and the reset limit.

## L6. Report the contribution

**Step:** Apply the main skill's output rules.
Report milestone hashes, net changes, author dates, selection reasons, check results, reset evidence, and limits.
Disclose date fallbacks. Push only when explicitly requested.

**Checkpoint: `contribution_report`** — The user can inspect each milestone, its checks and date, and the final branch state.

**Gate:** Report complete: **RETURN Step 4** with contribution complete.
Report lacks evidence: **RETURN L6**.
