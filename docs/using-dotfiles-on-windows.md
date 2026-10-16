# Using dotfiles on Windows

This guide installs [Purple4pur's dotfiles](https://github.com/purple4pur/dotfiles)
with [chezmoi](https://www.chezmoi.io/), then connects them to PowerShell and
optional applications. The original wiki guide was tested on Windows 10.
These updated instructions have not been validated on a Windows machine.

Run the commands in PowerShell as your normal user. Windows PowerShell 5.1 and
PowerShell 7 have separate profiles; configure each version you use.
For WSL, follow [the Linux guide](using-dotfiles-on-linux.md) inside the Linux
environment.

## 1. Install chezmoi and Starship

Install [Scoop](https://scoop.sh/) using its official instructions, then run:

```powershell
scoop install git chezmoi starship
```

Starship is optional; omit it if you prefer the default prompt.

## 2. Initialize and apply the dotfiles

Back up existing configuration you want to keep, especially `.vimrc`, `.vim`,
and application directories under `.config` in your user profile.

Initialize the repository, inspect the proposed changes, then apply them:

```powershell
chezmoi init https://github.com/purple4pur/dotfiles.git
chezmoi diff
chezmoi apply
```

For a fresh home directory, you can combine initialization and application:

```powershell
chezmoi init --apply https://github.com/purple4pur/dotfiles.git
```

Chezmoi deploys the configuration to your home directory. It does not install
applications, modify your PowerShell profile, or create the Windows junctions
shown below.

## 3. Enable the PowerShell setup

Create the current host's profile directory and file if they do not exist:

```powershell
New-Item -ItemType Directory -Path (Split-Path -Parent $PROFILE) -Force | Out-Null
if (!(Test-Path -LiteralPath $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE | Out-Null
}
notepad.exe $PROFILE
```

Append this line once, then save:

```powershell
. "$env:USERPROFILE\.config\.powershell_setup.ps1"
```

Optionally set your preferred editor before that line. For example, if Neovim
is installed and on `PATH`:

```powershell
$EDITOR = "nvim.exe"
```

The [PowerShell setup](../dot_config/dot_powershell_setup.ps1) defaults to
`notepad.exe`, adds Git helper functions, and initializes Starship when installed.
For example, `vims` opens your profile and `gst` runs `git status`.

Restart PowerShell, or reload the profile:

```powershell
. $PROFILE
```

Repeat this step in each PowerShell version or host you use, including the
VS Code PowerShell terminal if it uses a different profile. Display `$PROFILE`
in that host to find the correct file.

Starship needs no additional initialization line.
If the prompt shows missing glyphs, install a suitable font, such as a
[Nerd Font](https://www.nerdfonts.com/), and select it in your terminal settings.

## 4. Optional: connect Vim and Neovim

Install the editor you want to use. For example:

```powershell
scoop install vim neovim
```

Chezmoi deploys `.vim` and `.config\nvim`, while Windows editors normally look
for `vimfiles` and `%LOCALAPPDATA%\nvim`. Directory junctions connect those paths.

First inspect any existing destinations:

```powershell
Get-Item -LiteralPath "$env:USERPROFILE\vimfiles", "$env:LOCALAPPDATA\nvim" -Force -ErrorAction SilentlyContinue |
    Select-Object FullName, LinkType, Target
```

If a destination already points to the intended target, skip its `mklink`
command. If it contains an existing configuration, move it to a backup location
before continuing. An existing `_vimrc` may also take precedence over the
deployed `.vimrc`; back it up and remove it from the active location if you want
to use this repository's Vim settings.

Create the junction for each editor you installed:

```powershell
cmd /C mklink /J "$env:USERPROFILE\vimfiles" "$env:USERPROFILE\.vim"
cmd /C mklink /J "$env:LOCALAPPDATA\nvim" "$env:USERPROFILE\.config\nvim"
```

Directory junctions normally do not require administrator privileges. The
destination path must be absent, and the target directory must have been
deployed by chezmoi. Keep `.vimrc` and `.vim` even if you only use Neovim: its
configuration loads both.

Use a current Neovim release. Markdown preview also requires the `glow`
executable, and language servers must be installed and enabled separately in
[the LSP configuration](../dot_config/nvim/lua/lsp.lua).
See [the Vim configuration](../dot_vimrc) and
[the Neovim Lua configuration](../dot_config/nvim/lua/init.lua) for key mappings.

## 5. Optional: connect Scoop's mpv configuration

Install mpv from Scoop's extras bucket:

```powershell
scoop bucket add extras
scoop install mpv
```

Skip the bucket command if `extras` is already listed by `scoop bucket list`.
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

Close mpv before changing its configuration. If the path already points to
`%USERPROFILE%\.config\mpv`, no change is needed. Otherwise, preserve the
existing directory by moving it to an unused backup path. For example, if
`portable_config.backup` does not already exist:

```powershell
Move-Item -LiteralPath $mpvConfig -Destination "$mpvConfig.backup"
```

Skip the move if `portable_config` does not exist. Once the destination is
absent, create the junction:

```powershell
cmd /C mklink /J "$mpvConfig" "$env:USERPROFILE\.config\mpv"
```

This path applies to per-user Scoop installs. For global Scoop installs or
another mpv distribution, locate that installation's configuration directory
and adapt the junction destination.

## Update and customize

Update Scoop applications using `scoop update *`.

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

Use `chezmoi edit` to edit a managed file in the source, then `chezmoi apply`
to deploy it. If you edit the deployed file directly, use `chezmoi re-add` to
save it back to the source. Keep personal changes in your own fork if you want
to share them across machines. Profile additions and junctions are local setup
steps; repeat them on a new machine.

## Troubleshooting

- **Command not found:** reopen PowerShell after installation and check
  `Get-Command chezmoi` or the relevant application. Confirm its directory is
  on `PATH`.
- **Profile does not load:** verify `$PROFILE` in the affected host, and check
  `Get-ExecutionPolicy -List` if PowerShell reports that scripts are disabled.
  A shell launched with `-NoProfile` skips profile loading.
- **`mklink` reports an existing file:** inspect the destination; skip a correct
  junction or back up an existing configuration before creating it.
- **Editor settings are missing:** inspect the junction targets. In Neovim,
  `:echo stdpath('config')` shows the actual configuration directory; a custom
  `XDG_CONFIG_HOME` or `NVIM_APPNAME` can change it.
- **mpv settings are missing:** check the Scoop root and junction target, then
  restart mpv.
