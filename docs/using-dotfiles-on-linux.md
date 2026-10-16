# Using dotfiles on Linux

This guide installs [Purple4pur's dotfiles](https://github.com/purple4pur/dotfiles)
with [chezmoi](https://www.chezmoi.io/), then connects them to your shell.
The original wiki guide was tested on Ubuntu 20.04 LTS. Package availability
varies by distribution; these updated instructions have not been tested on every
Linux release.

## 1. Install chezmoi and Starship

Install Git with your distribution's package manager. Download and extract the
Linux binary for your architecture from the
[bin releases](https://github.com/marcosnils/bin/releases), then run these commands
from the directory containing it:

```bash
chmod +x bin
./bin install github.com/marcosnils/bin
export PATH="$HOME/.local/bin:$PATH"
bin install github.com/twpayne/chezmoi
bin install github.com/starship/starship
```

Add `export PATH="$HOME/.local/bin:$PATH"` once to `~/.bashrc`, before the shell
setup added below. Starship is optional; skip its install command if you prefer
the built-in prompt. See [bin](https://github.com/marcosnils/bin) for details.

## 2. Initialize and apply the dotfiles

Back up existing configuration files you want to keep, especially `~/.vimrc`,
`~/.vim`, `~/.tmux.conf`, and application directories under `~/.config`.
Run chezmoi as your normal user so it manages your home directory.

Initialize the repository, inspect the proposed changes, then apply them:

```bash
chezmoi init https://github.com/purple4pur/dotfiles.git
chezmoi diff
chezmoi apply
```

For a fresh home directory, you can combine initialization and application:

```bash
chezmoi init --apply https://github.com/purple4pur/dotfiles.git
```

Chezmoi copies configuration files into your home directory. It does not install
the applications that use them, and it does not automatically add the shell
setup to `~/.bashrc`.

## 3. Enable the Bash setup

Add this line once to `~/.bashrc`:

```bash
source "$HOME/.config/.bash_setup"
```

Open a new terminal, or reload the current shell:

```bash
source ~/.bashrc
```

The [Bash setup](../dot_config/dot_bash_setup) adds shell and Git aliases and
initializes Starship when available. Without Starship, it uses a built-in prompt.
For example, `gst` runs `git status` and `srcs` reloads `~/.bashrc`.

If you use tcsh instead, add the following to `~/.tcshrc` and restart tcsh:

```tcsh
source ~/.config/.tcsh_setup
```

Starship needs no additional initialization line. If prompt glyphs are missing,
select a suitable terminal font, such as a [Nerd Font](https://www.nerdfonts.com/).

## 4. Optional: use the application configurations

Install only the applications you want to use:

| Application | Configuration deployed by chezmoi | Notes |
| --- | --- | --- |
| Vim | `~/.vimrc`, `~/.vim/` | Themes and bundled plugins are included. |
| Neovim | `~/.config/nvim/` | Also loads `~/.vimrc` and `~/.vim/`; use a current release. |
| tmux | `~/.tmux.conf` | Start a new tmux server to load it. |
| mpv | `~/.config/mpv/` | The configuration requires mpv 0.37.0 or newer. |

For Vim and Neovim key mappings, read [the Vim configuration](../dot_vimrc) and
[the Neovim Lua configuration](../dot_config/nvim/lua/init.lua).
Neovim's Markdown preview also needs the `glow` executable; language servers
must be installed and enabled separately in
[the LSP configuration](../dot_config/nvim/lua/lsp.lua).

## Update and customize

Update binaries installed with bin using `bin update`.

Pull and apply the latest repository changes:

```bash
chezmoi update
```

To review an update before applying it, use:

```bash
chezmoi git pull -- --ff-only
chezmoi diff
chezmoi apply
```

For local changes to managed files, use `chezmoi edit ~/.vimrc` followed by
`chezmoi apply`, or edit the deployed file and run `chezmoi re-add ~/.vimrc`.
Keep changes in your own fork if you want to share them across machines.

## Troubleshooting

- **Command not found:** check that the application is installed and its binary
  directory is on `PATH`. Reopen the terminal after changing `PATH`.
- **Aliases or prompt missing:** confirm `~/.bashrc` sources `.bash_setup` and
  that you are running Bash. A login Bash shell also needs its login profile
  to source `~/.bashrc`.
- **Unexpected file changes:** inspect `chezmoi diff` before applying. Restore
  your backup or adjust the chezmoi source if a setting should be kept.
