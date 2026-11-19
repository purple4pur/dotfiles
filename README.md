# Purple4pur's dotfiles

Personal dotfiles, custom scripts, and coding agent skills, managed by [chezmoi](https://www.chezmoi.io/).

Use these pages to install the dotfiles or find a file:

- [Use dotfiles on Linux](docs/using-dotfiles-on-linux.md)
- [Use dotfiles on Windows](docs/using-dotfiles-on-windows.md)
- [Repository contents](docs/repository-contents.md): source paths, deployed paths, features, script requirements, and skill purposes.

## Repository contents

The repository includes these configurations and tools:

| Area | Contents |
| --- | --- |
| Shells | [Bash](dot_config/dot_bash_setup), [tcsh](dot_config/dot_tcsh_setup), and [PowerShell](dot_config/dot_powershell_setup.ps1) helpers, plus a [Starship prompt](dot_config/starship.toml). |
| Editors | [Vim settings](dot_vimrc), [Neovim settings](dot_config/nvim), bundled plugins, and [SystemVerilog ctags rules](dot_ctags). |
| Terminals | [tmux settings](dot_tmux.conf), terminal themes, [Goneovim settings](dot_config/goneovim/settings.toml), and [herdr bindings](dot_config/herdr/config.toml). |
| Media | [mpv profiles and controls](dot_config/mpv), playlist and preview scripts, Anime4K shaders, and a [hold-to-fast-forward script](dot_config/mpv/exact_scripts/fast-forward.lua). |
| Custom scripts | [Neovim launchers, a PATH helper, a Qwen Code container launcher, Docker Compose updates, Playwright setup, and AV1 conversion](custom_scripts). |
| Agent skills | [Local and external skills](dot_skills) for code style, reviews, Git commits, documentation, skill maintenance, and session reports. |

For editor mappings, read [the Vim configuration](dot_vimrc) and [the Neovim Lua configuration](dot_config/nvim/lua/init.lua).

## External resources

* [**`dot_vimrc`**](./dot_vimrc) - [mkitt/tabline.vim](https://github.com/mkitt/tabline.vim) w/ modification
* [**`dot_vim/colors/PaperColor.vim`**](./dot_vim/colors/PaperColor.vim) - [NLKNguyen/papercolor-theme](https://github.com/NLKNguyen/papercolor-theme) w/ whitespace modification
* [**`dot_vim/colors/onehalfdark.vim (onehalflight)`**](./dot_vim/colors/onehalfdark.vim) - [sonph/onehalf](https://github.com/sonph/onehalf) w/ modification
* [**`dot_vim/pack/plugins/start/vim-visual-multi`**](./dot_vim/pack/plugins/start/vim-visual-multi) - [mg979/vim-visual-multi](https://github.com/mg979/vim-visual-multi)
* [**`dot_config/nvim/lua/glow.nvim`**](./dot_config/nvim/lua/glow.nvim) - [ellisonleao/glow.nvim](https://github.com/ellisonleao/glow.nvim) w/ modification **(Archived upstream)**
* [**`dot_config/nvim/lua/mini.nvim`**](./dot_config/nvim/lua/mini.nvim) - [nvim-mini/mini.nvim](https://github.com/nvim-mini/mini.nvim) **(Active)**
* [**`dot_config/nvim/lua/nvim-lspconfig`**](./dot_config/nvim/lua/nvim-lspconfig) - [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) **(Active, but here will not update often)**
* [**`dot_config/mpv/exact_scripts/autoload.lua`**](./dot_config/mpv/exact_scripts/autoload.lua) - [mpv-player/mpv/.../autoload.lua](https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua)
* [**`dot_config/mpv/exact_scripts/modernz.lua`**](./dot_config/mpv/exact_scripts/modernz.lua) - [Samillion/ModernZ](https://github.com/Samillion/ModernZ) **(Active)**
* [**`dot_config/mpv/fonts/modernz-icons.ttf`**](./dot_config/mpv/fonts/modernz-icons.ttf) - [Samillion/ModernZ icon font](https://github.com/Samillion/ModernZ/blob/main/modernz-icons.ttf)
* [**`dot_config/mpv/exact_scripts/thumbfast.lua`**](./dot_config/mpv/exact_scripts/thumbfast.lua) - [po5/thumbfast](https://github.com/po5/thumbfast)
* [**`dot_config/mpv/shaders`**](./dot_config/mpv/shaders) - [bloc97/Anime4K](https://github.com/bloc97/Anime4K)
* [**`dot_skills/ponytail*`**](./dot_skills/ponytail) - [DietrichGebert/ponytail skills](https://github.com/DietrichGebert/ponytail/tree/main/skills)
* [**`dot_skills/caveman`**](./dot_skills/caveman) - [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman/tree/main/skills/caveman)
* [**`dot_skills/caveman-commit`**](./dot_skills/caveman-commit) - [JuliusBrussee/caveman caveman-commit](https://github.com/JuliusBrussee/caveman/tree/main/skills/caveman-commit)
* [**`dot_skills/convert-documents-to-markdown`**](./dot_skills/convert-documents-to-markdown) - [firecrawl/anydoc](https://github.com/firecrawl/anydoc/tree/main/skills/convert-documents-to-markdown)
* [**`dot_skills/interface-kit`**](./dot_skills/interface-kit) - [JuliusBrussee/skills](https://github.com/JuliusBrussee/skills/tree/main/skills/interface-kit)
* [**`dot_skills/modern-web-guidance`**](./dot_skills/modern-web-guidance) - [GoogleChrome/modern-web-guidance](https://github.com/GoogleChrome/modern-web-guidance/tree/main/skills/modern-web-guidance)
* [**`dot_skills/show-me`**](./dot_skills/show-me) - [humanlayer/skills show-me](https://github.com/humanlayer/skills/tree/main/plugins/show-me/skills/show-me)
* [**`dot_skills/write-docs`**](./dot_skills/write-docs) - [adhamhaithameid/write-skills](https://github.com/adhamhaithameid/write-skills/tree/main/skills/write-docs)
