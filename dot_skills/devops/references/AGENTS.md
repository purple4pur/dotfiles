# AGENTS.md

This repository holds operations documentation only. It carries no application
code and no runnable configuration.

## Writing

- Load the `write-docs` skill before you write or edit a document.
- Write prose in ASD-STE100 Simplified Technical English.
- Confirm each live-host fact on the host before you write it. Put the
  verification date on the page.

## Secrets

Record a secret as its path, its key names, and the steps to rotate it. Never
write the value, a credential, a private key, or a token.

## Layout

- `README.md` is the menu. Add one row for each operation.
- Operation documents live in `ops/`. One document covers one operation.
- Edit the document that owns a fact. Do not restate the fact in a second
  document.

## Commits

- Load the `record-each-step` skill. Commit on `main`, with one Conventional
  Commit for each logical change.

## Check before you commit

- The README links to the document, and the link resolves.
- The document names real paths and commands, and it carries the date of its
  measurements.
- The change contains no secret value.
- The tree is clean, and the commit subject follows Conventional Commits.
