# Purple4pur's dotfiles

All files are managed by [chezmoi](https://www.chezmoi.io/) .

* **[Using dotfiles on Windows](https://github.com/purple4pur/dotfiles/wiki/Using-dotfiles-on-Windows)**
* **[Using dotfiles on Linux](https://github.com/purple4pur/dotfiles/wiki/Using-dotfiles-on-Linux)**

Read more on [Wiki](https://github.com/purple4pur/dotfiles/wiki) !

## Warning!

Since there's file renaming/deletion in mpv script folder, but `chezmoi update/apply` will not remove the old files, which may cause mpv loading lua script you don't need, you are expected to:

* manaully delete old files in `~/.config/mpv/scripts`
* **OR** : delete the whole `~/.config/mpv/scripts` folder, then `chezmoi update/apply`

Related commit:

* [`7c510ab`](https://github.com/purple4pur/dotfiles/commit/7c510abfb002da0d8aebae8fb7a0f4dc827dda1d) (Nov 17, 2023)

## External Resources Used

* [bloc97/Anime4K](https://github.com/bloc97/Anime4K) [`4029bf7(v4.0.1)`](https://github.com/bloc97/Anime4K/tree/4029bf701ecaa15f163cdc49cffe5501c1acf410)
* [cyl0/ModernX](https://github.com/cyl0/ModernX) [`feca458`](https://github.com/cyl0/ModernX/tree/feca458b3eee0fd383a77d45632265372c607461) (with custom changes)
* [`autoload.lua` from mpv-player/mpv](https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua) [`d147a06`](https://github.com/mpv-player/mpv/blob/d147a06e60bfc10cb2fd7c66af7eb6871dba163e/TOOLS/lua/autoload.lua)
* [mg979/vim-visual-multi](https://github.com/mg979/vim-visual-multi) [`aec289a`](https://github.com/mg979/vim-visual-multi/tree/aec289a9fdabaa0ee6087d044d75b32e12084344)
