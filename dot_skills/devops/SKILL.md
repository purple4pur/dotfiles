---
name: devops
description: >
  Read and update the operations records in `$HOME/devops`. Use for devops and
  sysadmin work on any host: containers, systemd units, reverse proxies,
  tunnels, DNS, TLS, disks, backups, secret rotation, installs, deployments,
  and any other change to live machine state. Read the records before the work
  starts, and bootstrap them when `$HOME/devops` does not exist.
---

# DevOps records

Every machine keeps one documentation repository at `~/devops`. The repository
is the memory that outlives the session.

## Rules

- Read the records before you touch a host. The README names the machines, their access, and their documents.
- State each live fact once, in the document that owns it. Name the value and the date you measured it.
- Write a secret as its path, its key names, and the steps to rotate it. Never write the value.
- Follow the writing and commit rules of the repository you edit. Its `AGENTS.md` holds them.
- Add documentation only. The repository holds no application code and no runnable configuration.

## Steps

### 1. Read the records

**Step:** Run `test -d "$HOME/devops/.git"`. On a pass, read `~/devops/README.md` and `~/devops/AGENTS.md` in full.

**Checkpoint: `records_state`** — The test result, and after a pass, the machine table, the access paths, and the document list.

**Gate:** Pass: **CONTINUE Step 2**.
Fail: **ENTER Bootstrap**.

### 2. Route the fact

**Step:** Name the machine that owns the fact, then open that machine's repository. The local machine uses `$HOME/devops`. A remote host uses `~/devops` on that host, over `ssh`. The machine table in the README names each host and its access path.

**Checkpoint: `record_owner`** — The host, the repository path, and the document that already covers the topic, or "none".

**Gate:** One owner named: **CONTINUE Step 3**.
The owner has no repository: **ENTER Bootstrap**, on the owner.
The machine table omits the owner, and you verified its access yourself: **CONTINUE Step 3**, and add its row.
The owner is unreachable: **STOP** with the host name and the failed command.

### 3. Write the change

**Step:** Check the value on the machine now. Edit the owning document in `ops/`. If no document covers the operation, create `ops/<name>.md` and add its menu row. Write the value and today's date.

**Checkpoint: `record_update`** — The document holds the new value and the date, the menu links to it, and no other document repeats the fact.

**Gate:** The record matches the machine: **CONTINUE Step 4**.
The value is wrong or the link is broken: **RETURN Step 3**.
A secret value would enter the file: **STOP**, and apply the secret rule.

### 4. Commit

**Step:** Load the `record-each-step` skill. Commit on the branch that the repository's `AGENTS.md` names, or on the current branch when it names none. Use one Conventional Commit for the operation.

**Checkpoint: `clean_tree`** — `git status` is clean, and `git log -1` shows the record commit.

**Gate:** Clean: **COMPLETE**.
Unrelated changes are staged: **RETURN Step 4**.

## Conditional lanes

### Bootstrap

**Entry:** The machine that owns the fact has no `~/devops` Git repository.

**Step:** On that machine, do these steps:

1. Keep any files that the directory already holds.
2. Create the directory and the repository:

   ```bash
   mkdir -p ~/devops/ops
   git -C ~/devops init -b main
   ```

3. Copy `references/AGENTS.md` to `~/devops/AGENTS.md`, and `references/README.md` to `~/devops/README.md`. A remote host does not hold these files, so send them with `scp`.
4. Replace every value in angle brackets, and delete the template note.
5. Run the commands in its Verification section on that host, and write their output into the first pages under `ops/`.
6. Commit `chore: bootstrap the operations records`.

`references/AGENTS.md` is the canonical copy of the repository rules. Change it before you change an installed copy.

**Checkpoint: `bootstrap_result`** — `~/devops` holds `AGENTS.md`, `README.md`, `ops/` with one page, and one commit.

**Gate:** Present: **RETURN Step 2**.
Git or write access fails: **STOP** with the failed command.

## Report

End with the repository path, the document, its verification date, and the commit subject.
