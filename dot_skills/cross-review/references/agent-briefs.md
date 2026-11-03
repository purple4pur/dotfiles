# Agent briefs for cross-review

Use the brief for each planned dimension. Append the repository root, scope map, and shared rules from `SKILL.md`.
Keep reviewers read-only. Run independent reviewers in parallel within the host slot limit. Collect every result before cross-check.
Read the shared [STE rules](../../write-docs/references/ste.md) before you write findings. Preserve exact code and quoted evidence.

## Shared finding format

Each finder reports these fields:

```text
- file:line
- severity: Critical | Suggestion | Nice to have
- defect
- failure scenario: concrete trigger -> wrong outcome or measured cost
- suggested fix
- confidence: high | low
```

Drop a Suggestion if it has no concrete failure scenario. Report an uncertain Critical with low confidence and the evidence limit.
Use `No issues found — <what you examined>` for an empty result. Include the files, paths, or checks that support it.

## Shared scope rules

Read all files in the Step 1 scope map. Searches for call sites can reach outside that map. Keep file reads within scope.
If a read is truncated, read successive ranges until the complete file is available. Never infer the rest of a file.
On diff rounds, use the supplied diff file and pinned base. The orchestrator owns diff capture. Reviewers must not choose another base.
Verify usage claims with `rg`. Compute every cited metric. Record the command and result that support the finding.

## 1. correctness

Read each source file in scope. Read the complete function before you judge a line.
Identify the input, state, timing, or platform that causes an incorrect result.
Check inverted conditions, boundary errors, missing `await`, swallowed errors, reachable null values, and valid zero values that code treats as absent.
Check copied variables, races, synchronous calls in async handlers, and datetime assumptions.

## 2. cross-file

Trace exports and endpoints to their consumers. Check each call against the producer contract.
Trace each data field to its write and read sites. Check fields with missing producers or consumers.
Compare backend schemas, frontend types, and database columns for names, nullability, and types.
Verify usage evidence before you report an endpoint, export, or column as unused.

## 3. security

Read the domain document's non-goals and trust boundary first.
Check SQL injection, server-side request forgery (SSRF), secret exposure, cross-origin resource sharing (CORS), and input validation.
Check log forgery and unbounded writes. Trace untrusted inputs to the exposed operation.
Report missing authentication or rate limits only when a concrete exposure exists outside the declared boundary.

## 4. reuse

Review unnecessary code and dependencies. This dimension owns the over-engineering review. Do not invoke the standalone `ponytail*` skills.
Keep correctness, security, and performance defects with their own dimensions.
Rank whole-state findings by the largest useful reduction. Keep diff findings in diff order.

Add one tag to each finding:

- `delete`: code or a speculative feature has no reachable use. Search production code and tests before this verdict.
- `dedupe`: repeated logic has a named existing helper or a specific remedy.
- `yagni`: an abstraction has one implementation, or a configuration option has no user.
- `stdlib`: an established standard library operation can replace custom code.
- `native`: a platform operation can replace a dependency.
- `shrink`: the same behavior needs fewer lines. Show the replacement form.

Choose remedies in this order: `delete > shrink > extract`.
Create a helper only when at least three real call sites remain after the cleanup. Otherwise, keep the code inline.
Select one remedy. Do not report both extraction and inline replacement for the same finding.
A single smoke test is not unnecessary code without specific evidence.
End with `net: -<N> lines, -<M> deps possible.` Label estimates and their basis. Do not invent totals.

## 5. altitude

Check whether each operation belongs at its current layer.
Check business logic in routers, database access outside the data layer, and HTTP details in higher layers.
Identify local workarounds for upstream defects and abstractions with one caller.
Check custom external-response parsers. Identify unexpected shapes that cause silent incorrect data instead of a clear domain error.

## 6. consistency

Compare related routers and components. Cite the local example that establishes the convention.
Check asymmetric guards, validation, and error shapes. Explain the different outcome between related paths.
A missing guard on untrusted input can be Critical. Check comments against current behavior.

## 7. performance

Check N+1 queries, missing indexes against actual queries, and synchronous work in async handlers.
Check repeated external calls, large uncompressed responses, full UI rebuilds after selection, and unbounded memory growth.
State the input size or request load that causes the cost. Keep cold-path micro-optimizations outside the findings.

## 8. test-coverage

Inventory the existing tests first. Name the specific critical path without a test.
Describe a plausible code defect and whether the existing test would fail.
For tests that check strings, state the behavior those assertions cannot verify.
Use Suggestion for a missing test. Use Critical for a test that asserts incorrect behavior or permits a known defect.

## 9. build-test

Use the Step 1 commands. If a command is absent, inspect the manifests and report the absence explicitly.
Run one build command and one test command per side. Keep this dimension deterministic and read-only.
Report the command, working directory, exit code, counts, and complete failure text. Preserve failure text exactly.
Separate code failures from environment failures. Tag each result `[build]` or `[test]`.

## 10. removed-behavior

Run this dimension only on diff rounds. Review each deleted or replaced behavior.
State the invariant each removal enforced and where the replacement preserves it.
Compare renamed exports by behavior, including defaults, scope, and error propagation.
Trace consumers of changed literals, marker strings, keys, codes, and regular expressions.
Check format and schema changes against existing data. Identify migration and compatibility requirements.
Read the post-change files within scope. If proof requires a file outside scope, report low confidence and the missing check.
Do not claim an invariant is absent when the required evidence is unavailable.

## interface-kit

Run this dimension only when Step 1 detects UI. Read the installed `interface-kit` skill.
Use the shared finding fields. Keep its native priority as an additional field when useful.

Check these properties in priority order:

1. Accessibility: compute contrast for actual token pairs. Use 4.5:1 for ordinary text and 3:1 for large text or non-text elements.
   Check keyboard access, modal focus capture and restoration, icon-button labels, live regions, and 44×44px touch targets.
2. Typography: check font smoothing and tabular numbers for dynamic values.
3. Layout: check the 4/8px grid, concentric radii, and layered shadows.
4. Color and motion: check semantic tokens, animation frequency, reduced motion, JavaScript scrolls, and press feedback.
   Flag `transition: all` where it causes unintended animation.

Check native `alert`, `confirm`, and `prompt` calls when the project forbids them.
Compute cited metrics. Keep areas without defects out of the findings.

## Orchestrator checks

Merge entries only when the defect, location, and cause match. Keep the highest severity and every reporting dimension.
A single reuse finding can have executed evidence from usage searches. Evaluate that evidence without an automatic second-vote requirement.
Executed counter-evidence takes precedence over votes. Domain design claims make incompatible removals contested until the user decides.
Choose severity from the concrete impact. A pathological input with no data loss does not become Critical only because it returns HTTP 500.
