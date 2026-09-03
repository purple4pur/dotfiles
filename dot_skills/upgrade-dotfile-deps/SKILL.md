---
name: upgrade-dotfile-deps
description: >
  Upgrade vendored dependencies in the chezmoi dotfiles repo. README
  "External resources" is the dep manifest; vendors are plain copies, not
  submodules. Pull upstream latest to /tmp/deps, diff, classify, apply per
  category rules, regenerate help tags, refresh README, verify for real.
  Use for "upgrade deps", "sync deps to upstream", "check dep updates",
  "upgrade caveman/ponytail/mpv/nvim plugins", "refresh vendored copies".
---

# Upgrade Dotfile Deps

Upgrade vendored upstream copies in this repo. Vendored = plain files, no
submodules, no nested .git. Nothing pins versions; diff decides everything.

## Standing category rules (user-confirmed 2026-09-03)

| Category | Rule |
|------------|--------------------------------------------------------------|
| skills | Fully pick upstream, include new skills, drop local edits. Skip monorepo build infra (`generated/`, `registry.json`, `compile.mjs`, `*.mjs` at skills root). Never touch user-owned skills (cross-review, record-each-step, session-performance-report, stronger-skill). |
| breaking | Migrate carefully. Upgrade deprecated references/usages elsewhere in config too. Assume latest nvim — new APIs directly, no version guards, no deprecated APIs even in comments. |
| small fix | Straight copy of upstream file. |
| optional | Do NOT introduce unnecessary deps. New assets (shaders, colorschemes, modules) copied only if config references them. |

Intentional local mods stay unless user says otherwise for that dep:
glow.nvim (no auto-install line), onehalfdark (Diff* reverse), dot_vimrc
tabline rewrite, PaperColor (whitespace).

## Environment constraints

- Sandbox: uid 1000, no root/sudo. `~/.local/state` not writable — always set
  `XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME` to /tmp paths for headless nvim.
- Network: assume github reachable. If slow/unreachable, fallback ladder:
  1. plain clone/fetch
  2. release tarball via `https://ghfast.top/https://github.com/...` prefix
  3. codeload tarball `https://codeload.github.com/O/R/tar.gz/refs/heads/BR` — NO byte-range resume
  4. per-file raw fetch (api.github.com tree listing + raw.githubusercontent.com)
- Huge repo (mpv): never clone; fetch single raw files.
- Headless nvim: use `--headless`, NEVER `-es` (reads stdin as ex script, `-c` silently no-ops).
- No nvim binary? Portable tarball via ghfast.top, extract to /tmp, use once.
- Keep /tmp/deps after run — user may want later merges.

## Main line

### 1. Qualify: build dep inventory

**Step**

Read README "External resources" section. For each dep record: repo, vendored
path(s), shape (dir-copy / single-file / embedded-in-file), marked notes
(Active, w/ modification, will-not-update-often).

**Checkpoint: `dep_inventory`**

Table: repo | vendored path | shape | note. Embedded (e.g. tabline in
dot_vimrc) marked for manual compare only.

**Gate**

- Every README dep classified: **CONTINUE Step 2**.
- Vendored path missing on disk: **STOP**, report drift between README and repo.

### 2. Pull upstream latest to /tmp/deps

**Step**

Shallow-clone each dir-shaped repo: `git clone -q --depth 1 --single-branch
URL /tmp/deps/NAME`, parallel via `xargs -P 6`. Single-file deps: fetch raw
file (curl). Record HEAD date per clone.

**Checkpoint: `upstream_pulled`**

/tmp/deps populated; every repo passes `git rev-parse HEAD`; raw files exist.

**Gate**

- All present and valid: **CONTINUE Step 3**.
- Clone fails: **ENTER lane-network**.
- Repo huge, only subset needed: **ENTER lane-partial-fetch**.

### 3. Diff: classify each dep

**Step**

Compare vendor vs upstream. Dirs: `diff -rq --exclude=.git`. Files: `cmp`.
Flat-vendor vs restructured-upstream: match by basename (Anime4K pattern) and
diff layout (lspconfig pattern: which dirs exist on each side). For versioned
files, compare self-declared version vs latest release tag
(`api.github.com/repos/O/R/releases/latest`).

**Checkpoint: `classification`**

Per dep: SAME / BEHIND (pure upstream additions) / DIVERGED (vendor has local
edits) / BEHIND+DIVERGED / MAJOR (upstream restructure). Count changed files
and lines per dep.

**Gate**

- Classification complete for all deps: **CONTINUE Step 4**.
- Ambiguous direction (can't tell local mod from staleness): mark DIVERGED,
  decide at Step 4.

### 4. Report and decide

**Step**

Show one table: dep | vendor state | upstream state | verdict per category
rules. Breaking deps flagged. DIVERGED deps listed with exact local-edit
diff summary.

**Checkpoint: `plan`**

Decision per dep. Standing rules auto-decide SAME/BEHIND/small/optional.
DIVERGED needs user choice unless standing rule covers it (skills = full
upstream).

**Gate**

- Every dep has decision: **CONTINUE Step 5**.
- DIVERGED non-skill dep unresolved: **STOP**, ask user (keep mods vs pick
  upstream vs merge).
- Optional new assets undecided: default skip; note in report.

### 5. Apply

**Step**

Per decision:

- skills: replace dir wholesale (`rm -rf` + `cp -r`), add new skill dirs.
  Verify no vendor-only files lost first (`diff -rq | grep "^Only in"`).
- breaking: replace vendor with upstream runtime files only (exclude .git,
  .github, tests, Makefile, CI/dev configs; keep LICENSE/README/doc/lua/plugin
  or equivalent runtime set). Migrate config references to new API
  (e.g. lspconfig: drop `require('lspconfig')`, use `vim.lsp.config` +
  `vim.lsp.enable`; old `setup{}` examples become new-API comments).
- small fix: `cp` upstream file over vendor.
- optional: copy only config-referenced assets.

**Checkpoint: `applied`**

Every applied dep passes `cmp`/`diff -rq` vs its upstream source (excluding
deliberate exclusions).

**Gate**

- All applied deps match source: **CONTINUE Step 6**.
- Vendor-only file would be lost: **RETURN Step 4**, name the file.
- Breaking migration needs config change beyond mechanical edit:
  **ENTER lane-breaking**.

### 6. Regenerate help tags, refresh README

**Step**

If any vim/nvim plugin's `doc/*.txt` changed: upstream never ships
`doc/tags` — regenerate:

```sh
nvim --headless -u NONE -i NONE --cmd "set rtp^=VENDOR_DIR" \
  -c "helptags VENDOR_DIR/doc" -c quit
```

(XDG dirs set; tag sanity: grep a known-new tag.) Then update README
"External resources": bullet per dep, glob `name*` only if multiple vendored
dirs, upstream link deep-targets the actual skill/subpath when repo is
monorepo, notes (Active, w/ modification) reflect reality.

**Checkpoint: `docs_current`**

`doc/tags` exists, mtime after doc update, contains new-content tags. README
matches on-disk dep set exactly.

**Gate**

- Tags valid + README accurate: **CONTINUE Step 7**.
- No plugin help changed and README already accurate: skip sub-step, **CONTINUE Step 7**.
- nvim unavailable and download fails: record limit, leave tags deleted
  (stale tags worse than none), **CONTINUE Step 7** with warning in report.

### 7. Verify for real

**Step**

Never claim done on static review. Run, per change type:

- nvim config changed or plugin swapped: headless full config load +
  API-resolution probe:
  `nvim --headless -i NONE -c "lua ...io.open marker... " +qa` with XDG set;
  assert exit clean and marker written. Probe new API path end-to-end
  (e.g. `vim.lsp.config['server']` resolves through runtimepath append).
- lua touched: `assert(loadfile(f))` per file (via --headless nvim or luac).
- skills touched: vendor matches upstream source (`diff -rq`), SKILL.md
  frontmatter intact.
- mpv scripts: `cmp` vs upstream.
- No nvim/luac obtainable: state exactly which checks did not run. Do not
  report validated.

**Checkpoint: `verification_record`**

List: check | command | result. Include skipped checks with reason.

**Gate**

- All applicable checks pass: **CONTINUE Step 8**.
- Any check fails: **RETURN Step 5** (or Step 6 if docs), fix, re-run.
- Verification impossible in env: **STOP**, report exact blocker + what was
  NOT verified. Never fake pass.

### 8. Commit (optional)

**Step**

Offer to commit; commit only on explicit user approval. On approval:
`git status`, review diff by area, stage explicit paths (never -A bare).
Conventional subject ≤50 chars, body only when why non-obvious. Logical split
allowed: dep upgrades vs trim vs docs. Confirm clean tree after.

**Checkpoint: `commit_state`**

Either: `git log -1 --format='%h %s'` shows new commit and
`git status --short` empty — or — user declined and uncommitted changes left
in tree, reported.

**Gate**

- User approved + clean tree: **COMPLETE**.
- User declined or no answer: leave changes in working tree, **COMPLETE**
  with state note (what changed, what is uncommitted).

## Lanes

### lane-network (from Step 2)

Clone/fetch fails (TLS drop, timeout, hang). Work the fallback ladder in
Environment constraints. Parallel batch: rerun survivors individually with
per-command timeout; kill nothing else. Tarball path: no resume support —
delete partial, restart or switch source. Raw-file path: list files via
`api.github.com/repos/O/R/git/trees/BR?recursive=1`, fetch each from raw,
retry 2.
Exit: checkpoint `upstream_pulled` satisfied. Record which source succeeded
per repo (future runs start there).

### lane-partial-fetch (from Step 2)

Repo huge and dep is subset (mpv autoload.lua, Anime4K glsl). Fetch only
needed files flat by basename. If upstream reorganized into subdirs, resolve
each vendored basename to its upstream path via tree API before fetching.
Exit: subset complete; note unreferenced upstream files were skipped, not
missing.

### lane-breaking (from Step 5)

Upstream API/config restructure (lspconfig v2 pattern). Read upstream
README/migration notes + new config files first. Map every old-API usage in
repo config (`grep -rn OLD_API config/`). Migrate usage sites, keep commented
examples working in new API. Prove with Step 7 probe (new API resolves,
deprecated symbol absent from live code path).
Exit: Step 5 checkpoint satisfiable with migrated config.

## Non-goals

- No submodule conversion, no dep manager introduction.
- No updating user-owned skills, dot_vimrc-embedded code, or unrelated files.
- No pinning/lockfile creation.
- No speculative upgrade of deps user did not ask about beyond the report.
