# Purple4pur's dotfiles

Dotfiles are managed by [chezmoi](https://www.chezmoi.io/):

```
$ sudo snap install chezmoi --classic   # Linux
$ scoop install chezmoi                 # or Windows

$ chezmoi init --apply https://github.com/purple4pur/dotfiles.git   # First-time initialization
$ chezmoi update                                                    # Future udpates
```

## Common setups

Using [Starship](https://starship.rs/) for the shell prompt & [zoxide](https://github.com/ajeetdsouza/zoxide) for a smarter `cd`:

```
$ sudo snap install starship zoxide   # Linux
$ scoop install starship zoxide       # or Windows
```

Alternatively, Linux can install zoxide by:

```
$ curl -sS https://webinstall.dev/zoxide | bash
```

### bash

Append the following line to `~/.bashrc`:

```
source ~/.config/.bash_setup
```

### Powershell

Append the following line to `$PROFILE`, and DO NOT forget the leading `.`:

```
. ~\.config\.powershell_setup.ps1
```

## Windows-only setups

Create soft links for config files:

```
$ cmd /C mklink /J "C:\Users\<USERNAME>\vimfiles" "C:\Users\<USERNAME>\.vim"
$ rm ~\scoop\persist\mpv\portable_config
$ cmd /C mklink /J "C:\Users\<USERNAME>\scoop\persist\mpv\portable_config" "C:\Users\<USERNAME>\.config\mpv"
```

## Appendix: Scoop

[Scoop](https://scoop.sh/) is a package manager for Windows, which provides tons of UAC-free apps.

### Install

Scoop will be installed into `~/scoop` by default.

```
$ Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
$ irm get.scoop.sh | iex
```

### Config

```
$ scoop config proxy 127.0.0.1:10809 (or None)   # v2rayN default port
$ scoop config aria2-enabled True (or False)     # multithreaded download
```

### Apps

```
$ scoop bucket add extras
$ scoop install <app>
```

- aria2
- bat               : modern `cat`
- chezmoi
- dust              : modern `du`
- gcc               : nuwen.net minGW distro
- git
- make
- mpv
- ripgrep           : modern `grep`
- starship          : modern shell prompt
- tabby             : powerful ssh shell
- tealdeer          : tldr
- universal-ctags
- uutils-coreutils  : GNU coreutils in Rust
- vcxsrv            : X-Forwarding client
- versions/snipaste-beta
- versions/python38
- vim
- winscp
- zoxide            : smart `cd`