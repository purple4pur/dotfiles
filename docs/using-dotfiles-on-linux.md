# Use dotfiles on Linux

This guide installs [Purple4pur's dotfiles](https://github.com/purple4pur/dotfiles)
with [chezmoi](https://www.chezmoi.io/). You then enable the shell setup.
Package availability depends on your distribution.

## 1. Install chezmoi and Starship

Install Git with your distribution's package manager. Download the Linux binary
for your architecture from the [bin releases](https://github.com/marcosnils/bin/releases).
Extract the binary. Run these commands from the directory that contains `bin`:
Starship is optional. Skip its install command if you prefer the built-in prompt.

```bash
chmod +x bin
./bin install github.com/marcosnils/bin
export PATH="$HOME/.local/bin:$PATH"
bin install github.com/twpayne/chezmoi
bin install github.com/starship/starship
```

Add `export PATH="$HOME/.local/bin:$PATH"` once to `~/.bashrc`, before the shell
setup in step 3. See [bin](https://github.com/marcosnils/bin) for details.

## 2. Initialize and apply the dotfiles

Back up existing configuration files you want to keep.
Include `~/.vimrc`, `~/.vim`, `~/.tmux.conf`, and application directories under `~/.config`.
Run chezmoi as your normal user to manage your home directory.

Initialize the repository. Inspect the proposed changes before you apply them:

```bash
chezmoi init https://github.com/purple4pur/dotfiles.git
chezmoi diff
chezmoi apply
```

For a fresh home directory, initialize and apply the repository with one command:

```bash
chezmoi init --apply https://github.com/purple4pur/dotfiles.git
```

Chezmoi copies configuration files into your home directory. Install the
applications separately. Add the shell setup to `~/.bashrc` in step 3.

## 3. Enable the Bash setup

Add this line once to `~/.bashrc`:

```bash
source "$HOME/.config/.bash_setup"
```

Open a new terminal, or reload `~/.bashrc`:

```bash
source ~/.bashrc
```

The [Bash setup](../dot_config/dot_bash_setup) adds shell and Git aliases.
The setup initializes Starship when available. Without Starship, the setup uses
a built-in prompt. For example, `gst` runs `git status` and `srcs` reloads `~/.bashrc`.

If you use tcsh, add this line once to `~/.tcshrc`:

```tcsh
source ~/.config/.tcsh_setup
```

Restart tcsh to load the setup.

Starship needs no additional initialization line. If prompt symbols are missing,
select a terminal font that contains those symbols, such as a [Nerd Font](https://www.nerdfonts.com/).

## 4. Optional: use the application configurations

Install only the applications you want to use:

| Application | Configuration deployed by chezmoi | Notes |
| --- | --- | --- |
| Vim | `~/.vimrc`, `~/.vim/` | Themes and bundled plugins are included. |
| Neovim | `~/.config/nvim/` | Requires version 0.11.3 or newer. Also loads `~/.vimrc` and `~/.vim/`. |
| tmux | `~/.tmux.conf` | Start a new tmux server to load the configuration. |
| mpv | `~/.config/mpv/` | The configuration requires mpv 0.37.0 or newer. |

For Vim and Neovim key mappings, read [the Vim configuration](../dot_vimrc) and
[the Neovim Lua configuration](../dot_config/nvim/lua/init.lua).
Install the `glow` executable to use Neovim's Markdown preview.
Install language servers separately. Enable each server in
[the LSP configuration](../dot_config/nvim/lua/lsp.lua) with `vim.lsp.enable()`.
The supplied configuration leaves all servers disabled.
See the [bundled nvim-lspconfig requirements](../dot_config/nvim/lua/nvim-lspconfig/README.md#install)
for the Neovim version requirement.

## 5. Optional: enable coding agent skills

Chezmoi deploys the [bundled skills](../dot_skills) to `~/.skills`.
Create a symbolic link so your coding agent can find those skills:

| Coding agent | Skill directory |
| --- | --- |
| Codex and Qwen Code | `~/.agents/skills` |
| Claude Code | `~/.claude/skills` |
| OpenCode | `~/.config/opencode/skills` |

Confirm that `~/.skills` exists before you create a link.
If a destination already points to `~/.skills`, skip its commands.
If a destination contains existing skills, move that directory to a backup location first.

Confirm that each destination path is absent.
Run the commands for each coding agent you use:

```bash
# Codex and Qwen Code
mkdir -p "$HOME/.agents"
ln -s "$HOME/.skills" "$HOME/.agents/skills"

# Claude Code
mkdir -p "$HOME/.claude"
ln -s "$HOME/.skills" "$HOME/.claude/skills"

# OpenCode
mkdir -p "$HOME/.config/opencode"
ln -s "$HOME/.skills" "$HOME/.config/opencode/skills"
```

Start a new session in your coding agent to load the skills.

## Update and customize

Update binaries installed with bin:

```bash
bin update
```

Pull and apply the latest repository changes:

```bash
chezmoi update
```

To review an update before you apply the changes, use:

```bash
chezmoi git pull -- --ff-only
chezmoi diff
chezmoi apply
```

Edit a managed file in the chezmoi source, then apply the change:

```bash
chezmoi edit ~/.vimrc
chezmoi diff
chezmoi apply
```

If you edit the deployed file directly, save the change in the source:

```bash
chezmoi re-add ~/.vimrc
```

Keep changes in your own fork to share them across machines.

## Troubleshooting

- **Command not found:** check that the application is installed. Confirm that
  its binary directory is on `PATH`. Reopen the terminal after you change `PATH`.
- **Aliases or prompt missing:** confirm `~/.bashrc` sources `.bash_setup` and
  that you use Bash. For a login Bash shell, make sure its login profile sources
  `~/.bashrc`.
- **Unexpected file changes:** inspect `chezmoi diff` before you apply the changes.
  Restore your backup or edit the chezmoi source to keep a setting.
