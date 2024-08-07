# Purple4pur's dotfiles

All files are managed by [chezmoi](https://www.chezmoi.io/) .

* **[Using dotfiles on Windows](https://github.com/purple4pur/dotfiles/wiki/Using-dotfiles-on-Windows)**
* **[Using dotfiles on Linux](https://github.com/purple4pur/dotfiles/wiki/Using-dotfiles-on-Linux)**

Read more on [Wiki](https://github.com/purple4pur/dotfiles/wiki) !

For vim/nvim plugin common usages, please refer to [`~/.vimrc`](dot_vimrc) and [`~/.config/nvim/lua/init.lua`](dot_config/nvim/lua/init.lua) .

## External Resources Used

* [bloc97/Anime4K](https://github.com/bloc97/Anime4K) [`4029bf7(v4.0.1)`](https://github.com/bloc97/Anime4K/tree/4029bf701ecaa15f163cdc49cffe5501c1acf410)
* [cyl0/ModernX](https://github.com/cyl0/ModernX) [`3f2ed6b(v0.6.1)`](https://github.com/cyl0/ModernX/commit/3f2ed6b993059c6986bf34be3998048c50547187) (with custom change)
* [`autoload.lua` from mpv-player/mpv](https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua) [`d147a06`](https://github.com/mpv-player/mpv/blob/d147a06e60bfc10cb2fd7c66af7eb6871dba163e/TOOLS/lua/autoload.lua)
* [purple4pur/mpv-scripts](https://github.com/purple4pur/mpv-scripts)
* [NLKNguyen/papercolor-theme](https://github.com/NLKNguyen/papercolor-theme)
* [mg979/vim-visual-multi](https://github.com/mg979/vim-visual-multi) [`aec289a`](https://github.com/mg979/vim-visual-multi/tree/aec289a9fdabaa0ee6087d044d75b32e12084344)
* [purple4pur/glow.nvim](https://github.com/purple4pur/glow.nvim) (forked from [ellisonleao/glow.nvim](https://github.com/ellisonleao/glow.nvim) , with custom change)
* [purple4pur/mini.nvim](https://github.com/purple4pur/mini.nvim) (forked from [echasnovski/mini.nvim](https://github.com/echasnovski/mini.nvim) )
* [purple4pur/nvim-lspconfig](https://github.com/purple4pur/nvim-lspconfig) (forked from [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) )

## Develop Note

```bash
git remote add glow-nvim https://github.com/purple4pur/glow.nvim.git
git remote add mini-nvim https://github.com/purple4pur/mini.nvim.git
git remote add lspconfig https://github.com/purple4pur/nvim-lspconfig.git

git subtree add/pull --prefix=dot_config/nvim/lua/glow.nvim --squash glow-nvim main
git subtree add/pull --prefix=dot_config/nvim/lua/mini.nvim --squash mini-nvim master
git subtree add/pull --prefix=dot_config/nvim/lua/nvim-lspconfig --squash lspconfig master
```
