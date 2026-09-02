# Agent briefs — cross-review

Prompt skeletons per agent. The orchestrator copies the skeleton, appends repo root + scope map, and launches all agents in one parallel response. Shared launch rules live in SKILL.md; they apply to every brief below except `build-test`.

## Shared finding format (all finder agents)

```
- file:line
- severity: Critical | Suggestion | Nice to have
- what's wrong
- failure scenario: concrete trigger → wrong outcome (or concrete cost). No scenario = do not report the Suggestion.
- suggested fix
- confidence: high | low
```

Empty return: `No issues found — <what you examined>` with evidence of the walk.

## Shared scope rules (all finder agents)

- The Step 1 scope map is your territory: read exactly those files fully. Do not wander outside scope (greps for call sites may reach anywhere — reads stay in scope).
- A file over ~25,000 characters comes back truncated from one read (`isTruncated`): keep paging with offset/limit until you have all of it. Reviewing from the first screenful is a whiff.
- On a diff round, read the diff from the file path the orchestrator hands you — NEVER run `git diff` yourself. An agent-chosen base produces two-dot phantom regressions (main's fixes appearing as your branch's regressions), and shell output truncates large diffs silently.

## 1. correctness

Read every source file in scope. For each line ask: what input, state, timing, or platform makes this wrong? Hunt: inverted conditions, off-by-one, missing await, swallowed errors, None/null on rare-but-reachable paths, falsy-zero treated as missing, copy-paste variable mistakes, race conditions, sync blocking calls inside async handlers, naive datetime pitfalls. Read the enclosing function before judging a line.

## 2. cross-file

Two directions. Consumer: for every export/endpoint, find call sites, check each against the contract. Producer: for every field the data model adds, find read sites — a field read but never written (or written but never read) is a finding. Compare backend schemas ↔ frontend types ↔ DB columns field by field (names, nullability, types). Dead endpoints, dead exports, dead columns.

## 3. security

SQL injection (query construction, string interpolation), SSRF (user input reaching external URLs/params), secrets (hardcoded, logged, committed; JS-bundle exposure of server-side keys), CORS wildcards, input validation gaps (length, NaN/Inf, negative ids), log forging, unbounded writes. Exclusions: no "add auth/rate limiting" unless the design doc does not declare the boundary AND a concrete exposure exists. Read the domain doc's non-goals first.

## 4. reuse

Duplicated logic across files (name the existing helper or name the helper to extract — a duplication finding naming nothing is not a finding), repeated literal blocks (field lists, error strings, SQL fragments) spelled multiple ways, dead code (functions/branches/imports/classes nothing reaches — grep before claiming).

## 5. altitude

Is each piece at the right layer? Business logic in routers, DB access outside the data layer, HTTP details leaking upward, bandaids compensating for an upstream bug, single-caller abstractions. Enumeration traps: hand-rolled parsing of external API responses where an unexpected shape silently yields wrong data instead of a loud domain error.

## 6. consistency

Parallel families (routers per resource, sibling components): does one member have a guard/validation/error shape its siblings lack? Asymmetric failure between siblings; if the missing guard is on untrusted input, say it may be Critical. Convention drift measured against a cited local example. Comments contradicting code.

## 7. performance

N+1 queries, missing indexes vs actual WHERE/JOIN patterns, blocking I/O in async handlers, uncached repeated external calls, missing response compression for large payloads, frontend rebuild-everything-on-selection patterns, unbounded accumulation. No micro-opts on cold paths; state the scale at which each finding bites.

## 8. test-coverage

Inventory existing tests first. Name specific untested critical paths (never "coverage is low"). Mutation-think: if this code had bug X, would the existing suite go red? Tests that assert string presence instead of behavior are weak — name what they would miss. Missing test = Suggestion; a test asserting the WRONG thing or weakened to let bugs pass = Critical.

## 9. build-test (deterministic, no review)

Discover commands from manifests. Run ONE build + ONE test command per side. Report verbatim: exact command line, working dir, exit code, pass/fail counts, full text of any failure (do not summarize). Distinguish code-caused failures from environment failures (informational only). If a side has no build/test command, state that explicitly — it is a deterministic fact. Do not fix anything. Source tag every result `[build]` or `[test]`.

## 10. removed-behavior (diff rounds only)

Owns the deleted/replaced lines — they exist only in the diff, the current tree carries no trace. For each removal ask: what invariant did it enforce, and where is it re-established? Specifically: removed/renamed exports (compare against the replacement as BEHAVIOR, not names — a flipped default, a narrowed scope, an error that stopped propagating), changed literals that distant consumers match by shape (marker strings, keys, codes, regex text), and rename/format/schema changes against data that already exists (migration / split-brain). Read the post-change files to check re-establishment; when the re-establishment would live outside the diff, report at `Confidence: low` and say the check could not be completed — do not assert it is missing.

## ponytail-review lens

Over-engineering only; correctness/security/performance out of scope. One line per finding: `<file>:L<line>: <tag> <what>. <replacement>.` Tags: `delete:` (dead code, speculative feature — replacement: nothing), `stdlib:` (hand-rolled, standard library ships it), `native:` (dependency doing what the platform does), `yagni:` (one-implementation abstraction, config nobody sets), `shrink:` (same logic, fewer lines — show the form). Grep for usages before calling anything dead — check tests and e2e too. End with `net: -<N> lines possible.` If nothing: `Lean already. Ship.` Do not flag a single smoke test as bloat.

## interface-kit lens (UI rounds only)

Audit against the priority stack: accessibility (computed WCAG contrast ratios for the actual token pairs — show the numbers, ≥4.5:1 text / 3:1 large+non-text; keyboard operability of every interactive element; focus trap/restore in modals; aria-label on icon-only buttons; live regions; 44×44px touch targets) → typography (font smoothing, tabular-nums on dynamic numbers) → spatial (4/8px grid, concentric radius, layered shadows) → color/motion (semantic tokens not hardcoded hex, frequency-matched animation, no `transition: all`, reduced-motion respected including JS scrolls, press feedback). Also flag any native alert/confirm/prompt if the project bans them. Format: `[CRITICAL|HIGH|MEDIUM|LOW] <file>:<line> — <what> → <fix>`. Compute, don't eyeball. Clean areas get no padding findings.

## Orchestrator cross-check reminders (Step 3)

- Dedup: same defect + location + root cause keeps one entry, highest severity, list all lenses that flagged it.
- Probe runnable claims before ruling (the NaN case: reading pydantic's actual output killed the "reads 500 forever" mechanism).
- Domain doc is the design-intent judge: lens says dead, doc says planned → contested, held for user.
- Severity honesty: pathological input without data loss is Suggestion even when it 500s in prod (verified max_length case).
