<!-- Template for a new machine. Replace every <slot>, then delete this note. -->

# <title>

<One sentence: what this repository records.>

## Machines

| Name | Role | Access | Records |
|---|---|---|---|
| `<hostname>` | <role> | <ssh alias, address, or port> | <this repository, or the path on another host> |

## <hostname>

| Fact | Value |
|---|---|
| Host | `<hostname>`, <model or cloud instance> |
| OS | <distribution and kernel> |
| Root disk | <size, use, free> (<YYYY-MM-DD>) |

<One paragraph: what this machine runs, and how you reach it.>

## Operations

| Operation | Document | Scope |
|---|---|---|
| <operation> | [ops/<name>.md](ops/<name>.md) | <one line> |

Add one page for each operation under `ops/`. Then add a row here.

## Conventions

- Run commands as `<user>`. A `# sudo` mark means run the command with `sudo`.
- Record a secret as its path, its key names, and the steps to rotate it. Never
  write the value.
- Check live values against the host before you trust a number in a page. Each
  page names the date of its measurements.
- Edit the page that owns a fact. Do not restate the fact in a second page.

## Verification

The facts in this repository come from the live host on <YYYY-MM-DD>. These
commands produced them:

```bash
hostnamectl
df -h /
systemctl --failed
```

<Add the commands that produced this host's facts.>
