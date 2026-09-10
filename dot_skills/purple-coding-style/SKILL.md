---
name: purple-coding-style
description: "Apply coding style and conventions whenever creating or editing source code in any language, including features, fixes, refactors, tests, and scripts. Use for purple-coding-style or coding convention requests. Prefer official language formatter style; otherwise enforce surrounding indentation, lazy line wrapping, local alignment, and affirmative illustrative comments. Excludes prose-only tasks and read-only code explanations."
---

# Purple Coding Style

Apply style to every new or edited source region. Preserve intended behavior.

## Contract and precedence

- Inputs: requested change, target source, applicable project instructions,
  language/toolchain, formatter configuration, and surrounding code.
- Output: requested source change with verified style and concise check results.
- Scope: style accompanies authorized implementation. Keep unrelated code and
  user edits intact. Repository-wide cleanup requires that scope in the task.
- Dependencies: existing language tools and project checks. This skill needs no
  additional package or custom formatter.
- Respect explicit user instructions and applicable repository requirements.
  Resolve the remaining style choices using the order below.

1. **Official formatter first.** If the language has an official formatter,
   use its style. Official means maintained or designated by the language
   project; popularity alone supplies no such authority. Examples: Go `gofmt`,
   Rust `rustfmt`, Dart `dart format`.
2. Use the project-pinned version and supported project configuration for that
   formatter. Its output overrides each contested rule below, including
   indentation, wrapping, and alignment. Keep that output stable on rerun.
3. Apply the detailed rules wherever official formatting leaves discretion.
   If no official formatter exists, apply them directly. An existing mandated
   third-party formatter remains a repository requirement; identify that
   authority accurately. Preserve existing formatter configuration.

## Detailed rules

### Indentation

- For edits, follow the nearest surrounding logical block's indentation,
  including tabs versus spaces and indentation width.
- For a new file, or when surrounding style gives no usable evidence, use
  four spaces per level.
- Preserve syntax-required whitespace, such as Make recipe tabs and embedded
  language constraints. Apply language rules separately to embedded regions.

### Line wrapping

- Wrap lazily. Consider wrapping a code line only above 250 characters,
  measured after removing leading indentation. This is a consideration
  threshold, not a hard maximum. Preserve valid, readable long literals or
  indivisible expressions when splitting would harm correctness or clarity.
- Keep existing sensible multiline structures. Use line breaks for statement
  and logical block structure independently of the wrapping threshold.
- For function, method, constructor, and similar callable declarations with
  three or more parameters, place each parameter on its own line and align
  their starts to one continuation column. Apply this rule regardless of the
  250-character threshold. Count each declaration's parameter list separately.
  Call-site arguments follow the general line-wrapping rules.
  Official formatter output still takes precedence.
- Wrap prose in comment blocks at 80 characters after removing leading
  indentation. Count comment markers and spaces after them toward the 80.
  Apply this to multiline documentation prose as well.
- Preserve exact URLs, commands, directives, literal examples, and tables when
  prose reflow would damage their meaning. Record material exceptions.

### Alignment and logical blocks

- Within one contiguous logical group, align variable definitions at matching
  structural columns, especially initializer operators.
- Align repeated operators across consecutive related statements, such as
  `=`, `+=`, or `<=`. Align like operators in corresponding syntactic roles;
  preserve expression meaning and evaluation order.
- Start each new logical group with a blank line and restart its alignment.
  Use the smallest padding needed within that group. Introduce braces or scopes
  only when language semantics require them.
- Let official formatting determine the final columns when it changes manual
  alignment.

Example where no controlling formatter changes spacing:

```text
item_count  = read_count();
buffer_size = item_count * item_width;

bytes_read    += chunk_size;
bytes_pending += queued_size;
```

### Comments

- Add illustrative comments for large logic sections, complicated logic, and
  tricky code. Explain purpose, invariants, ordering, units, or a useful example
  at the point where a reader needs it.
- Name the **DOs**: describe the action to take and why it works. Never name the
  **NOT-DOs** in authored explanatory comments. Express constraints positively:
  `// Hold the lock while publishing the shared snapshot.`
- Keep simple code self-explanatory through clear names. Scale comment detail
  with reasoning burden. Preserve required legal text, exact quotations, and
  machine-readable directives.

## Main line

Discover scope → resolve style → edit → verify → report.
Keep checkpoint evidence in task notes or the final response; separate report
files are unnecessary.

### 1. Discover scope

**Step:** Read target regions and applicable instructions. Identify languages,
existing indentation, new files, and the authorized change boundary.

**Checkpoint: `scope`** — Target files, language per region, instruction paths,
surrounding indentation evidence, and intended change.

**Gate:** Scope known: **CONTINUE Step 2**. Missing target or ambiguous intent
prevents a safe edit: **STOP** and request the missing detail.

### 2. Resolve style

**Step:** Inspect toolchain, formatter configuration, and project commands.
Establish official formatter status from reliable language/toolchain evidence.
Record the winning rule for conflicting settings; use defaults above for
unconstrained choices.

**Checkpoint: `style_plan`** — Formatter identity, authority, version/config
when available, scoped command, effective rules, and any unavailable evidence.

**Gate:** Rules resolved and tools available, or no formatter required:
**CONTINUE Step 3**. Formatter unavailable or official status unresolved:
**ENTER Formatter evidence lane**. Required instructions remain contradictory:
**STOP** with the exact conflict.

### 3. Edit source

**Step:** Implement the requested change using `style_plan`. Group related
logic, align locally, and add affirmative explanations where reasoning needs
support. Run the formatter on the smallest supported authorized scope. Inspect
whole-file output when range formatting is unavailable; preserve user edits.

**Checkpoint: `source_diff`** — Requested change and formatter output, with
unrelated changes excluded or a required whole-file effect identified.

**Gate:** Diff within authorized scope: **CONTINUE Step 4**. Style needs repair:
**RETURN Step 3**. Formatter necessarily changes beyond authorized scope:
**STOP** with the concrete affected scope and request a decision.

### 4. Verify result

**Step:** Review the diff against effective indentation, wrap thresholds,
alignment groups, and comment rules. Check formatter stability using its check
mode or a second pass. Run relevant existing syntax/build/test checks for the
implementation; scale checks to behavior changed.

**Checkpoint: `checks`** — Commands/results, manual style findings, formatter
stability result, applicable exceptions, and skipped checks with reasons.

**Gate:** Checks pass: **CONTINUE Step 5**. Source defect: **RETURN Step 3**.
Wrong style authority: **RETURN Step 2**. Tool unavailable:
**ENTER Formatter evidence lane**. Other check blocked: record exact limit and
**CONTINUE Step 5** with validation explicitly incomplete.

### 5. Report completion

**Step:** Summarize the change and checks. Name the controlling formatter or
fallback rules only when useful; disclose material exceptions and limits.

**Checkpoint: `handoff`** — Changed paths, verification result, and any
remaining blocker. Claim verified style only for checks actually completed.

**Gate:** Requested change complete and checks pass: **COMPLETE**. Required
validation blocked: **STOP** with the partial result and exact blocker.

## Formatter evidence lane

**Entry:** Required formatter cannot run, or official status lacks evidence.

**Step:** Check existing project tools, pinned dependencies, and available
official documentation. Follow host permission rules for any required install
or network access. Preserve formatter precedence even when its binary is
missing. Continue useful manual style work using established rules.

**Checkpoint: `formatter_limit`** — Tool/evidence searched, exact failure,
resolved authority if available, and checks still possible.

**Gate:** Evidence/tool restored: **RETURN Step 2**. Still unavailable: perform
remaining safe checks, then **STOP** with partial work and the unverified
formatter claim. Never report manual inspection as a formatter pass.
