---
name: upgrade-dotfile-deps
description: >
  Inspect or upgrade vendored dependencies in the chezmoi dotfiles repo. Use for
  upgrade deps, sync deps to upstream, check dep updates, upgrades of vendored
  skills or mpv and nvim plugins, and refresh vendored copies.
---

# Upgrade dotfile dependencies

Use README's External resources as the dependency manifest.
Vendors are plain copies, without submodules or nested `.git` directories.
Compare upstream evidence instead of adding version pins or a dependency manager.

## Standing decisions

Apply these category rules, confirmed on 2026-09-03:

| Category | Action |
|---|---|
| Skills | Take full upstream content for selected external skills, including replacement of local edits. Add skills only within scope. |
| Breaking changes | Migrate runtime content, affected configuration, and examples to current APIs. |
| Small fixes | Copy the upstream file. |
| Optional assets | Copy only assets referenced by configuration. Skip unnecessary dependencies. |

Derive skill ownership from README's manifest. Preserve every skill outside its external-resource entries.
Skip skill-monorepo infrastructure: `generated/`, `registry.json`, `compile.mjs`, and `*.mjs` at the skills root.
Assume latest nvim. Use current APIs directly, without version guards or deprecated APIs in code and comments.

Preserve these intentional local changes unless the user authorizes replacement for that dependency:

- glow.nvim: removed auto-install line.
- onehalfdark: `Diff*` reverse attributes.
- dot_vimrc: tabline rewrite.
- PaperColor: whitespace changes.

### Caveman repository scope

The 2026-09-13 decision restricts `JuliusBrussee/caveman` to `skills/caveman` and `skills/caveman-commit`.
Map both to the same-named `dot_skills/` directories. New upstream skills do not expand this allowlist.
Use two explicit README entries with deep links. This rule overrides generic skill rules and README globs.

Remove previously vendored extras only after proving repository provenance and absence of user-owned content or unresolved local edits.
Record exact removal paths before applying. Preserve unrelated skills.
Other repositories keep their manifest scope and category rules.

## Tool constraints

Use user-level tools and host permissions. A fallback source requires the same network authority as the original source.
If GitHub fetches fail, use this source order:

1. Plain clone or fetch.
2. Release tarball through `https://ghfast.top/https://github.com/...`.
3. Codeload tarball through `https://codeload.github.com/O/R/tar.gz/refs/heads/BR`.
4. Tree listing from `api.github.com/repos/O/R/git/trees/BR?recursive=1`, then `raw.githubusercontent.com` files.

Codeload does not support byte-range resume. Fetch huge-repository subsets directly instead of cloning mpv.
Use nvim `--headless`, never `-es`, which can read stdin as Ex commands and bypass intended `-c` checks.
Set `XDG_CACHE_HOME`, `XDG_DATA_HOME`, and `XDG_STATE_HOME` to task-owned paths under `/tmp` for headless nvim.
If nvim is absent, obtain a permitted portable tarball under `/tmp` through the fallback source.
Keep `/tmp/deps` after the run for later merges.

## Workflow

Inventory → fetch → classify → decide → apply → refresh docs → verify → report or commit.

### 1. Build the inventory

**Step:** Read README's External resources and resolve the requested mode and dependency scope.
Check-only requests permit reads and temporary fetches. Upgrade requests permit selected changes under the standing rules.
Record initial user changes and each repository, vendor path, shape, and note.
Mark embedded code for manual comparison. Record selected skills, exclusions, and removal candidates with provenance and local-edit status.

**Checkpoint: `dep_inventory`** — Every selected dependency has a path, shape, scope, mode, and preservation rule.

**Gate:** Inventory complete: **CONTINUE Step 2**.
Missing manifest path: **STOP** with the drift.
Extra skill provenance or local edits unresolved: **STOP** with exact paths and the missing preservation decision.

### 2. Fetch upstream into /tmp/deps

**Step:** Shallow-clone directory dependencies, with up to six independent fetches in parallel:

```bash
git clone -q --depth 1 --single-branch URL /tmp/deps/NAME
```

Fetch single files from raw URLs. Use Partial fetch for huge repositories, including mpv.
Record clone commit IDs and dates. Record archive or raw URLs, available revisions, source types, and file checks.
Validate archives by their contents, not `git rev-parse`.

**Checkpoint: `upstream_pulled`** — Complete selected sources with recorded provenance under `/tmp/deps`.

**Gate:** Sources valid: **CONTINUE Step 3**.
Fetch fails: **ENTER Network fallback**. Huge repository or subset: **ENTER Partial fetch**.
Required allowlisted skill absent: **STOP** with the path. Keep sibling skills outside selection.
Network authority unavailable: **STOP** with the exact fetch and permission limit.

### 3. Classify differences

**Step:** Compare directories with `diff -rq --exclude=.git` and files with `cmp`.
For restructured sources, resolve vendored basenames to upstream paths and compare directory layouts.
For versioned files, compare declared versions with `api.github.com/repos/O/R/releases/latest`.
Count changed files and lines.

**Checkpoint: `classification`** — Each selected dependency has one state:
`SAME`, `BEHIND` for pure upstream additions, `DIVERGED` for local edits, `BEHIND+DIVERGED`, or `MAJOR` for restructure.
Record uncertain direction as `DIVERGED` with its evidence limit.

**Gate:** Comparisons complete: **CONTINUE Step 4**. Missing comparison: **RETURN Step 3**.

### 4. Decide changes

**Step:** Show dependency, vendor state, upstream state, and category decision in one table.
Flag breaking changes and summarize exact local differences. Apply standing rules where they cover the change.
Default undecided optional assets to skip. Record every authorized removal path.

**Checkpoint: `plan`** — Decisions, preservation rules, exclusions, and exact removals cover every selected dependency.

**Gate:** Check-only mode: **COMPLETE** with classification, sources, exclusions, and limits. Leave the repository unchanged.
Upgrade decisions resolved: **CONTINUE Step 5**.
Diverged non-skill dependency lacks a standing decision: **STOP** for keep, replace, or merge.

### 5. Apply the plan

**Step:** Verify complete selected sources and inventory vendor-only files before replacement or deletion.
Apply only recorded decisions:

- Skills: replace authorized directories and add skills only within scope. Remove only recorded extras.
  Check `diff -rq` for vendor-only files before deletion. Return unaccounted files to Step 4.
- Breaking changes: copy runtime files, licenses, README, docs, Lua, and plugins where applicable.
  Exclude `.git`, `.github`, tests, Makefile, and CI or development configuration.
  Migrate configuration and examples to current APIs, including `vim.lsp.config` and `vim.lsp.enable` for lspconfig.
- Small fixes: copy the upstream file.
- Optional assets: copy only configuration-referenced files.

**Checkpoint: `applied`** — Files match upstream through `cmp` or `diff -rq`, except deliberate exclusions and preserved modifications.
The scoped skill set matches its allowlist, and authorized extras are absent.

**Gate:** Applied state matches the plan: **CONTINUE Step 6**.
Wrong skill scope or unaccounted vendor-only file: **RETURN Step 4** before further replacement.
Non-mechanical migration required: **ENTER Breaking migration**. Other mismatch: **RETURN Step 5**.

### 6. Refresh help tags and README

**Step:** If plugin `doc/*.txt` changed, regenerate `doc/tags` with temporary XDG directories:

```bash
nvim --headless -u NONE -i NONE --cmd "set rtp^=VENDOR_DIR" \
  -c "helptags VENDOR_DIR/doc" -c quit
```

Confirm tags are newer than changed docs and contain a known new tag.
Refresh README entries, deep upstream links, and Active or modification notes.
Use globs only for multiple vendored directories unless a repository rule requires explicit entries.

**Checkpoint: `docs_current`** — Required tags are valid, and README matches the dependency set on disk.

**Gate:** Docs current or no refresh needed: **CONTINUE Step 7**.
Incorrect tags or README: **RETURN Step 6**.
Nvim unavailable and download fails: remove stale tags, record the limit, and **CONTINUE Step 7** with incomplete tag validation.

### 7. Verify changes

**Step:** Run applicable checks:

- Nvim changes: load the full configuration headlessly with temporary XDG directories.
  Require a clean exit and written probe marker. Exercise the new API through the actual runtime path.
- Lua changes: run `assert(loadfile(f))` per file through headless nvim or `luac`.
- Skill changes: compare with selected upstream sources and validate frontmatter.
  For caveman, assert exactly the two allowed skills remain from that repository and README names both.
  Confirm unrelated and user-owned skills are unchanged.
- Mpv scripts: compare with upstream through `cmp`.

**Checkpoint: `verification_record`** — Check, command, result, and skipped checks with exact reasons.

**Gate:** Applicable checks pass: **CONTINUE Step 8**.
Source or runtime failure: **RETURN Step 5**. Documentation failure: **RETURN Step 6**.
Required tools unavailable: **STOP** with the partial result and exact unverified checks.
Static inspection alone does not establish runtime validation.

### 8. Report or commit

**Step:** Review the diff and apply the output rules below.
Commit only when requested or authorized by an active workflow. Stage explicit paths and preserve unrelated user changes.
Use a Conventional Commit subject of at most 50 characters. Add a body only when the reason needs explanation.
Split distinct upgrades, removals, and docs when useful. Otherwise, leave changes uncommitted and report their paths.

**Checkpoint: `commit_state`** — Verified task commit and tree state, or recorded uncommitted paths.

**Gate:** Authorized commit succeeds and the tree is clean: **COMPLETE**.
Commit not requested: **COMPLETE** with uncommitted state.
Commit fails: repair and **RETURN Step 8**. Missing authority: **STOP** with the exact limit.

## Conditional lanes

### Network fallback

**Entry:** Clone or fetch fails.

**Step:** Follow the fallback source order under Tool constraints, with the same network authority for every source.
Retry failed batch members individually with timeouts. Stop only task-owned fetches.
Restart partial tarballs or switch sources. Retry raw files twice after listing paths through the tree API.
Record the successful route so later runs can start there.

**Checkpoint: `fallback_sources`** — Complete selected sources with provenance and the successful fetch route.

**Gate:** Sources complete: **RETURN Step 2** to validate them.
All routes fail or authority unavailable: **STOP** with exact failures and missing sources.

### Partial fetch

**Entry:** A huge repository contains only a needed subset.

**Step:** Fetch needed files only. For flat vendors, resolve each basename through the tree API before fetching.
Record unreferenced files as skipped, not missing.

**Checkpoint: `partial_sources`** — Selected subset complete, with resolved paths and exclusions.

**Gate:** Subset complete: **RETURN Step 2**. Fetch fails: **ENTER Network fallback**.
Ambiguous basename: **STOP** with candidate paths.

### Breaking migration

**Entry:** Upstream changes APIs or configuration beyond a mechanical replacement.

**Step:** Read upstream migration notes, README, and new configuration first.
Find every old API usage with `rg` and migrate code and examples.
Plan Step 7's probe to establish new API resolution and absence of live deprecated usage.

**Checkpoint: `migration`** — Every affected usage has a current replacement and an end-to-end verification probe.

**Gate:** Migration complete: **RETURN Step 5**. Missing evidence: **RETURN Breaking migration**.
Required behavior unresolved: **STOP** with the exact conflict.

## Output and non-goals

Report selected and excluded dependencies, source revisions, classifications, decisions, and exact removals.
Include configuration migrations, README and tag status, verification commands and results, skipped checks, and commit state.

Keep user-owned skills, embedded dot_vimrc code, and unrelated files outside upgrade scope.
This skill introduces no submodules, dependency manager, version pins, or lockfiles.
Report unrequested dependency updates without applying them.

## Output rules

Read [STE rules](../write-docs/references/ste.md) for English prose. This reference does not invoke the `write-docs` workflow.
Keep the user's language, exact evidence, paths, commands, and native syntax.
STE takes precedence over caveman fragments. Check prose before delivery and revise failures.
Report material limits and only checks that ran.
