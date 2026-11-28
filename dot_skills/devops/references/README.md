<!-- Template for a new machine. Replace every value in angle brackets, then delete this note. -->

# Ops reference — <hostname>

This repository records how I build and maintain `<hostname>`. It holds
documentation only. Use it as a menu: open the document for the operation you
need.

## Machines

| Name | Role | Access | Records |
|---|---|---|---|
| `<hostname>` | <role> | <ssh alias, address, or port> | This repository |
| `<other host>` | <role> | <access path> | `<path>` on that host |

## <hostname>

| Fact | Value |
|---|---|
| Host | `<hostname>`, <model or cloud instance> |
| OS | <distribution, kernel> |
| Root disk | <size, use, free> (<YYYY-MM-DD>) |

<One paragraph: what this machine runs, and how you reach it.>

### <Access route or subsystem>

<A short section for each route or subsystem that a reader must know before
they touch the machine, for example a proxy, tunnel, or remote desktop.>

## Dotfiles

<The chezmoi source path, and the commands to review and apply a change.>

## Operations

| Operation | Document | Scope |
|---|---|---|
| <operation> | [ops/<name>.md](ops/<name>.md) | <one line> |

## Conventions

- Run commands as `<user>`. A `# sudo` mark means run the command with `sudo`.
- Record a secret as its path, its key names, and the steps to rotate it. Never
  write the value.
- Check live values against the host before you trust a number in a page. Each
  page names the date of its measurements.
- Edit the page that owns a fact. Do not restate the fact in a second page.
- Record a fact on the machine that owns it. A fact about another host belongs
  in that host's repository.

## Verification

The facts in this repository come from the live host on <YYYY-MM-DD>. Run these
commands to check them:

```bash
hostnamectl
df -h /
systemctl --failed
```

## Add an operation

1. Create `ops/<name>.md` for one operation.
2. Add a row to the **Operations** table.
3. Commit on `main` with a Conventional Commit subject.
