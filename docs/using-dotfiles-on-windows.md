# Use dotfiles on Windows

This guide installs [Purple4pur's dotfiles](https://github.com/purple4pur/dotfiles)
with [chezmoi](https://www.chezmoi.io/). You then enable the PowerShell setup
and connect optional applications. These instructions have not been tested on
a Windows machine.

Run the commands in PowerShell as your normal user. Windows PowerShell 5.1 and
PowerShell 7 have separate profiles. Configure each version you use.
For WSL, follow [the Linux guide](using-dotfiles-on-linux.md) inside the Linux
environment.

## 1. Install chezmoi and Starship

Install [Scoop](https://scoop.sh/) with its official instructions. Install these applications:
Starship is optional. Omit `starship` if you prefer the default prompt.

```powershell
scoop install git chezmoi starship
```

## 2. Initialize and apply the dotfiles

Back up existing configuration files you want to keep.
Include `.vimrc`, `.vim`, and application directories under `.config` in your user profile.

Initialize the repository. Inspect the proposed changes before you apply them:

```powershell
chezmoi init https://github.com/purple4pur/dotfiles.git
chezmoi diff
chezmoi apply
```

For a fresh home directory, initialize and apply the repository with one command:

```powershell
chezmoi init --apply https://github.com/purple4pur/dotfiles.git
```

Chezmoi copies configuration files into your home directory. Install the
applications separately. Add the PowerShell setup to your profile in step 3.
Create directory junctions in steps 4 through 6 for the applications you use.

## 3. Enable the PowerShell setup

Create the current host's profile directory and file if they do not exist:

```powershell
New-Item -ItemType Directory -Path (Split-Path -Parent $PROFILE) -Force | Out-Null
if (!(Test-Path -LiteralPath $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE | Out-Null
}
notepad.exe $PROFILE
```

Append this line once. Save the profile:

```powershell
. "$env:USERPROFILE\.config\.powershell_setup.ps1"
```

If Neovim is installed and on `PATH`, optionally set it as your editor before the setup line:

```powershell
$EDITOR = "nvim.exe"
```

The [PowerShell setup](../dot_config/dot_powershell_setup.ps1) defaults to
`notepad.exe`. The setup adds Git helper functions and initializes Starship when installed.
For example, `vims` opens your profile and `gst` runs `git status`.

Restart PowerShell, or reload the profile:

```powershell
. $PROFILE
```

Repeat step 3 in each PowerShell version or host you use.
Include the VS Code PowerShell terminal if that terminal uses a different profile.
Display `$PROFILE` in each host to find the correct file.

Starship needs no additional initialization line.
If prompt symbols are missing, install a font that contains those symbols, such as a
[Nerd Font](https://www.nerdfonts.com/). Select the font in your terminal settings.

## 4. Optional: connect Vim and Neovim

Install the editor you want to use. For example:

```powershell
scoop install vim neovim
```

Chezmoi deploys `.vim` and `.config\nvim` in your user profile.
Vim normally uses `%USERPROFILE%\vimfiles` on Windows. Neovim normally uses `%LOCALAPPDATA%\nvim`.
A directory junction connects an editor's configuration directory to the directory that chezmoi manages.

First inspect any existing destinations:

```powershell
Get-Item -LiteralPath "$env:USERPROFILE\vimfiles", "$env:LOCALAPPDATA\nvim" -Force -ErrorAction SilentlyContinue |
    Select-Object FullName, LinkType, Target
```

If a destination already points to the intended target, skip its `mklink`
command. If a destination contains an existing configuration, move that configuration
to a backup location before you continue.
An existing `_vimrc` can take precedence over the deployed `.vimrc`.
To use this repository's Vim settings, move `_vimrc` to a backup location.

Confirm that the destination path is absent and the target directory exists before each command.
Create the junction for each editor you installed:

```powershell
cmd /C mklink /J "$env:USERPROFILE\vimfiles" "$env:USERPROFILE\.vim"
cmd /C mklink /J "$env:LOCALAPPDATA\nvim" "$env:USERPROFILE\.config\nvim"
```

Directory junctions normally do not require administrator privileges.
Keep `.vimrc` and `.vim` even if you use only Neovim. The Neovim configuration loads both.

Use Neovim 0.11.3 or newer, as required by the
[bundled nvim-lspconfig](../dot_config/nvim/lua/nvim-lspconfig/README.md#install).
Install the `glow` executable to use Neovim's Markdown preview.
Install language servers separately. Enable each server in
[the LSP configuration](../dot_config/nvim/lua/lsp.lua) with `vim.lsp.enable()`.
The supplied configuration leaves all servers disabled.
See [the Vim configuration](../dot_vimrc) and
[the Neovim Lua configuration](../dot_config/nvim/lua/init.lua) for key mappings.

## 5. Optional: connect Scoop's mpv configuration

Run `scoop bucket list` to check for the `extras` bucket.
If `extras` is absent, add the bucket:

```powershell
scoop bucket add extras
```

Install mpv from the `extras` bucket:

```powershell
scoop install mpv
```

The supplied mpv configuration requires version 0.37.0 or newer.

For a standard per-user Scoop install, mpv's persistent configuration is at
`%USERPROFILE%\scoop\persist\mpv\portable_config`. If you set a custom `SCOOP`
directory, use that root:

```powershell
$scoopRoot = if ($env:SCOOP) { $env:SCOOP } else { Join-Path $env:USERPROFILE "scoop" }
$mpvConfig = Join-Path $scoopRoot "persist\mpv\portable_config"
Get-Item -LiteralPath $mpvConfig -Force -ErrorAction SilentlyContinue |
    Select-Object FullName, LinkType, Target
```

Close mpv before you change its configuration. If `$mpvConfig` already points to
`%USERPROFILE%\.config\mpv`, skip the move and junction commands.
If `portable_config` does not exist, skip the move command.
Otherwise, move that directory to an unused backup path.
Confirm that `$mpvConfig.backup` is absent before you use this example:

```powershell
Move-Item -LiteralPath $mpvConfig -Destination "$mpvConfig.backup"
```

Confirm that `$mpvConfig` is absent and `%USERPROFILE%\.config\mpv` exists.
Create the junction:

```powershell
cmd /C mklink /J "$mpvConfig" "$env:USERPROFILE\.config\mpv"
```

The path above applies to per-user Scoop installs. For a global Scoop install
or another mpv distribution, find that installation's configuration directory.
Use that directory as the junction destination.

## 6. Optional: enable coding agent skills

Chezmoi deploys the [bundled skills](../dot_skills) to `%USERPROFILE%\.skills`.
Create a directory junction so your coding agent can find those skills:

| Coding agent | Skill directory |
| --- | --- |
| Codex and Qwen Code | `%USERPROFILE%\.agents\skills` |
| Claude Code | `%USERPROFILE%\.claude\skills` |
| OpenCode | `%USERPROFILE%\.config\opencode\skills` |

Confirm that `%USERPROFILE%\.skills` exists before you create a junction.
If a destination already points to that directory, skip its commands.
If a destination contains existing skills, move that directory to a backup location first.

Confirm that each destination path is absent.
Run the commands for each coding agent you use:

```powershell
# Codex and Qwen Code
New-Item -ItemType Directory -Path "$env:USERPROFILE\.agents" -Force | Out-Null
cmd /C mklink /J "$env:USERPROFILE\.agents\skills" "$env:USERPROFILE\.skills"

# Claude Code
New-Item -ItemType Directory -Path "$env:USERPROFILE\.claude" -Force | Out-Null
cmd /C mklink /J "$env:USERPROFILE\.claude\skills" "$env:USERPROFILE\.skills"

# OpenCode
New-Item -ItemType Directory -Path "$env:USERPROFILE\.config\opencode" -Force | Out-Null
cmd /C mklink /J "$env:USERPROFILE\.config\opencode\skills" "$env:USERPROFILE\.skills"
```

Start a new session in your coding agent to load the skills.

## Update and customize

Update Scoop and its applications:

```powershell
scoop update
scoop update *
```

Pull and apply the latest repository changes:

```powershell
chezmoi update
```

To inspect an update first:

```powershell
chezmoi git pull -- --ff-only
chezmoi diff
chezmoi apply
```

Edit a managed file in the chezmoi source, then apply the change:

```powershell
chezmoi edit "$env:USERPROFILE\.vimrc"
chezmoi diff
chezmoi apply
```

If you edit the deployed file directly, save the change in the source:

```powershell
chezmoi re-add "$env:USERPROFILE\.vimrc"
```

Keep personal changes in your own fork to share them across machines.
Repeat the profile additions and junction setup on each new machine.

## Troubleshooting

- **Command not found:** reopen PowerShell after installation.
  Check `Get-Command chezmoi` or the relevant application. Confirm its directory is
  on `PATH`.
- **Profile does not load:** verify `$PROFILE` in the affected host.
  Check `Get-ExecutionPolicy -List` if PowerShell reports that scripts are disabled.
  A shell launched with `-NoProfile` does not load the profile.
- **`mklink` reports an existing file:** inspect the destination.
  Skip a correct junction. Back up an existing configuration before you create a junction.
- **Editor settings are missing:** inspect the junction targets. In Neovim,
  `:echo stdpath('config')` shows the actual configuration directory.
  A custom `XDG_CONFIG_HOME` or `NVIM_APPNAME` can change that directory.
- **mpv settings are missing:** check the Scoop root and junction target.
  Restart mpv.
