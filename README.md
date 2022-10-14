# Purple4pur's dotfiles

Dotfiles are managed by [chezmoi](https://www.chezmoi.io/):

```
$ sudo snap install chezmoi --classic  # Linux
$ scoop install chezmoi                # or Windows

$ chezmoi init --apply https://github.com/purple4pur/dotfiles.git  # First-time initialization
$ chezmoi update                                                   # Future udpates
```

## Common setups

Using [Starship](https://starship.rs/) for a shell prompt:

```
$ sudo snap install starship  # Linux
$ scoop install starship      # or Windows
```

- bash:

Append the following line to `~/.bashrc`:

```
source ~/.config/.bash_setup
```

- Powershell:

Append the following line to `$PROFILE`:

```
TODO
```

Other related apps:

- tmux
- mpv

## Windows only setups

Create soft links for config files:

```
cmd /C mklink /J "C:\Users\<USERNAME>\vimfiles" "C:\Users\<USERNAME>\.vim"
cmd /C mklink /J "C:\Users\<USERNAME>\AppData\Roaming\mpv" "C:\Users\<USERNAME>\.config\mpv"
```