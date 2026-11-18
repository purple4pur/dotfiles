---
name: purple-coding-style
description: >
  Apply coding conventions when creating or editing source code in any language,
  including features, fixes, refactors, tests, and scripts. Use for
  purple-coding-style or coding convention requests. Excludes prose-only tasks
  and read-only code explanations.
---

# Purple coding style

Apply style to every new or edited source region. Preserve intended behavior.

## Scope and precedence

Apply style within the authorized source change and its affected alignment blocks.
Preserve neighboring content, behavior, unrelated code, and user edits. Repository-wide cleanup requires explicit scope.
Use existing language tools and project checks. Preserve formatter configuration.

Resolve style in this order:

1. Follow explicit user instructions and applicable repository requirements.
2. Use an official language formatter with the project-pinned version and supported configuration.
   Official means maintained or designated by the language project. Examples include `gofmt`, `rustfmt`, and `dart format`.
3. Let official output control indentation, wrapping, and alignment. Require stable output on rerun.
4. Apply the detailed rules where official formatting leaves discretion, or where no official formatter exists.
   A mandated third-party formatter remains a repository requirement. Describe its authority accurately.

## Detailed rules

### Indentation

- Follow the nearest logical block's tabs or spaces and indentation width.
- For new files or unclear surrounding style, use four spaces per level.
- Preserve syntax-required whitespace, including Make recipe tabs. Apply each embedded language's rules to its region.

### Line wrapping

- Consider code wrapping only above 250 characters, excluding leading indentation. This threshold is not a hard maximum.
- Preserve long literals or indivisible expressions when splitting harms correctness or clarity.
- Keep sensible existing multiline structures. Use line breaks for statement and block structure independently of the threshold.
- For callable declarations with at least three parameters, put each parameter on its own line at one continuation column.
  Count each declaration's parameter list separately. This rule applies regardless of line length.
  Call-site arguments follow the general wrapping rule. Official formatter output takes precedence.
- Wrap comment and documentation prose at 80 characters, excluding leading indentation but including comment markers and following spaces.
- Preserve exact URLs, commands, directives, literal examples, and tables when reflow would damage meaning. Record material exceptions.

### Alignment and logical blocks

- When editing definitions, assignments, or aligned statements, recompute padding across the complete affected block.
  Include neighbors whose content is unchanged. Choose shared columns from the widest participating field.
- Bound blocks by blank lines, section-heading comments, control flow, scopes, or changes of purpose.
  Keep nested blocks independent. If boundaries are unclear, use the smallest contiguous related group at one nesting level.
- Align corresponding structural columns in variable definitions, especially initializer operators.
- Align like operators in consecutive related statements, including `=`, `+=`, and `<=`.
  Preserve expression meaning and evaluation order.
- Start each new logical group with a blank line and restart alignment. Use the smallest required padding.
  Add braces or scopes only when language semantics require them.
- Let the official formatter determine final columns where its output changes manual alignment.

Example without a controlling formatter:

```text
item_count  = read_count();
buffer_size = item_count * item_width;

bytes_read    += chunk_size;
bytes_pending += queued_size;
```

### Comments

- Add illustrative comments for large logic sections, complex logic, and tricky code.
  Explain purpose, invariants, ordering, units, or a useful example where the reader needs that context.
- Describe the required action and why it works. Express authored explanatory constraints positively:
  `// Hold the lock while publishing the shared snapshot.`
  Never describe the forbidden alternative in authored explanatory comments.
- Keep simple code clear through names. Scale comment detail to the required reasoning.
- Preserve legal text, exact quotations, and machine-readable directives.

## Workflow

Discover scope → resolve style → edit → verify → report.
Keep evidence in task notes or the final response. This skill requires no separate report file.

### 1. Discover the scope

**Step:** Read target regions and local instructions.
Identify languages, new files, surrounding indentation, authorized changes, and complete affected alignment blocks.

**Checkpoint: `scope`** — Target files, language per region, instruction paths, indentation evidence, block boundaries, and intended change.

**Gate:** Scope known: **CONTINUE Step 2**.
Missing target or intent prevents a safe edit: **STOP** for the missing detail.

### 2. Resolve the style

**Step:** Inspect the toolchain, formatter configuration, and project commands.
Establish formatter authority from language or toolchain evidence. Record the winning rule for each conflict.

**Checkpoint: `style_plan`** — Formatter identity, authority, version, configuration, scoped command, effective rules, and unavailable evidence.

**Gate:** Rules resolved and required tools available: **CONTINUE Step 3**.
No formatter required: **CONTINUE Step 3**.
Formatter or authority unavailable: **ENTER Formatter evidence**.
Required instructions conflict: **STOP** with the exact conflict.

### 3. Edit the source

**Step:** Implement the requested change with `style_plan`.
Realign each affected block and add affirmative comments where the logic needs explanation.
Run the formatter on the smallest supported authorized scope.
If only whole-file formatting exists, inspect its full diff and preserve user edits.

**Checkpoint: `source_diff`** — Requested change, formatting output, neighboring padding changes, and any required whole-file effect.

**Gate:** Diff stays within scope: **CONTINUE Step 4**. Style needs repair: **RETURN Step 3**.
Formatter requires changes beyond scope: **STOP** with the concrete diff and request a decision.

### 4. Verify the result

**Step:** Check indentation, wrapping, comments, and every statement in each affected alignment block.
Confirm shared columns and block boundaries, including neighbors whose content did not change.
Check formatter stability with its check mode or a second pass.
Run existing syntax, build, or test checks appropriate to the behavior change.

**Checkpoint: `checks`** — Commands, results, manual findings, formatter stability, alignment findings, exceptions, and skipped checks with reasons.

**Gate:** Checks pass: **CONTINUE Step 5**.
Source, style, or block boundary fails: **RETURN Step 3**. Wrong authority: **RETURN Step 2**.
Tool unavailable: **ENTER Formatter evidence**.
Other check blocked: record the exact limit and **CONTINUE Step 5** with incomplete validation.

### 5. Report the result

**Step:** Summarize changed paths and check results. Name material exceptions and limits.
Mention the controlling formatter or fallback rules when useful. Apply the output rules below.

**Checkpoint: `handoff`** — The user can locate the change and assess its completed and incomplete checks.

**Gate:** Requested change and checks complete: **COMPLETE**.
Required validation blocked: **STOP** with the partial result and exact blocker.

## Formatter evidence

**Entry:** A required formatter cannot run, or its official status lacks evidence.

**Step:** Check project tools, pinned dependencies, and available official documentation.
Follow host permission rules for installation or network access. Preserve formatter precedence when its binary is missing.
Complete useful manual work under the established rules.

**Checkpoint: `formatter_limit`** — Searched tools and evidence, exact failure, resolved authority, and remaining possible checks.

**Gate:** Tool or evidence restored: **RETURN Step 2**.
Still unavailable: complete safe checks, then **STOP** with the partial work and unverified formatter claim.
Report manual inspection as manual inspection, never as a formatter pass.

## Output rules

Read [STE rules](../write-docs/references/ste.md) for English prose. This reference does not invoke the `write-docs` workflow.
Keep the user's language and exact evidence, terms, paths, commands, code, and required formats.
Keep native commit syntax. Use affirmative explanatory comments where source conventions permit them.
STE takes precedence over caveman fragments. Check prose before delivery and revise failures.
Report material limits and only checks that ran.
