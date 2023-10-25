# Purple4pur's dotfiles

Read more on [Wiki](https://github.com/purple4pur/dotfiles/wiki) !

Dotfiles are managed by [chezmoi](https://www.chezmoi.io/):

```
$ sudo snap install chezmoi --classic   # Linux
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
