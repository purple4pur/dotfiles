# Repository contents

This reference records the configurations, scripts, and coding agent skills in this repository.
Source links point to the files that you edit.
Deployed paths use the default home directory layout.
The [Linux guide](using-dotfiles-on-linux.md) and [Windows guide](using-dotfiles-on-windows.md) cover installation and application setup.

## Chezmoi source names

Chezmoi converts source names into deployed names:

| Source name | Deployed name or behavior |
| --- | --- |
| `dot_` | A leading dot. For example, `dot_vimrc` becomes `~/.vimrc`. |
| `executable_` | Removes the prefix and sets execute permissions. |
| `private_` | Removes the prefix and restricts access permissions. |
| `exact_` | Removes the prefix and removes entries absent from the source directory. |

[`.chezmoiignore`](../.chezmoiignore) excludes `README.md` and `docs/` from deployment.
Chezmoi deploys scripts to `~/scripts`, without an automatic addition to `PATH`.
Applications, shell profile additions, and coding agent skill links require separate setup.

## Shell configurations

The shell files provide shared Git helpers and shell-specific settings:

| Source | Deployed path | Contents |
| --- | --- | --- |
| [Bash setup](../dot_config/dot_bash_setup) | `~/.config/.bash_setup` | Shell aliases, Git aliases, Starship initialization, and a fallback prompt. |
| [tcsh setup](../dot_config/dot_tcsh_setup) | `~/.config/.tcsh_setup` | Shell aliases, Git aliases, Starship initialization, a fallback prompt, and history search keys. |
| [PowerShell setup](../dot_config/dot_powershell_setup.ps1) | `~/.config/.powershell_setup.ps1` | Git functions, the `vims` profile editor, and optional Starship initialization. |
| [Starship configuration](../dot_config/starship.toml) | `~/.config/starship.toml` | User and host display, directory display, prompt symbols, and text labels for tool modules. |

`gst` runs `git status`, `gd` runs `git diff`, and `glg` shows the Git history graph.
In Bash and tcsh, `srcs` reloads the shell profile.
PowerShell uses `$EDITOR` for `vims` and defaults to `notepad.exe`.

## Editor configurations

Vim and Neovim share the Vim configuration and runtime files:

| Source | Deployed path | Contents |
| --- | --- | --- |
| [Vim configuration](../dot_vimrc) | `~/.vimrc` | PaperColor theme, four-space indentation, search settings, mappings, and custom status and tab lines. |
| [Vim runtime](../dot_vim) | `~/.vim/` | PaperColor and One Half themes, vim-visual-multi, and SystemVerilog file detection. |
| [Neovim entry point](../dot_config/nvim/init.vim) | `~/.config/nvim/init.vim` | Adds the Vim runtime, loads `~/.vimrc`, and loads the Lua configuration. |
| [Neovim Lua configuration](../dot_config/nvim/lua/init.lua) | `~/.config/nvim/lua/init.lua` | Loads plugins and language server settings. Adds terminal mappings and configuration commands. |
| [Neovim plugins](../dot_config/nvim/lua/plugins.lua) | `~/.config/nvim/lua/plugins.lua` | Configures bundled glow.nvim and mini.nvim modules. |
| [Language server configuration](../dot_config/nvim/lua/lsp.lua) | `~/.config/nvim/lua/lsp.lua` | Diagnostic settings and mappings for attached language servers. |
| [ctags configuration](../dot_ctags) | `~/.ctags` | SystemVerilog file extensions, symbol patterns, and file exclusions. |

Vim loads `~/.vimrc.local` when that file exists.
The repository does not supply that file.
Neovim requires version 0.11.3 or newer for the bundled nvim-lspconfig.
Language servers require separate installation and activation in `lsp.lua`.
The supplied configuration leaves all servers disabled.
The Markdown preview requires the `glow` executable.

The Neovim configuration enables these mini.nvim modules:

- `completion`, `cursorword`, `diff`, and `files`
- `indentscope`, `jump2d`, `map`, and `move`
- `splitjoin`, `starter`, `statusline`, `surround`, and `trailspace`

These mappings provide entry points to the editor features.
`<leader>` is the default backslash key unless your configuration changes `mapleader`.

| Mapping | Vim | Neovim |
| --- | --- | --- |
| `<leader>ee`, `<leader>ev`, `<leader>et` | Open netrw in the current window, a vertical split, or a tab. | Open mini.files in the current window, a vertical split, or a tab. |
| `<leader>T` | Open a terminal tab when Vim supports terminals. | Open a terminal tab. |
| `Ctrl+\` in terminal mode | Return to normal mode. | Return to normal mode. |
| `<leader>p` | No repository mapping. | Preview Markdown with glow.nvim. |
| `<leader>dd` | No repository mapping. | Toggle the mini.diff overlay. |
| `<leader>mm` | No repository mapping. | Toggle the mini.map window. |
| `<leader>dz` | No repository mapping. | Remove trailing spaces and final blank lines. |
| `[d`, `]d` | No repository mapping. | Go to the previous or next diagnostic. |

## Terminal and desktop configurations

The repository includes terminal settings and theme assets:

| Source | Deployed path | Contents and setup |
| --- | --- | --- |
| [tmux configuration](../dot_tmux.conf) | `~/.tmux.conf` | Window and pane numbering starts at one. Includes window reorder keys, a popup terminal, and a custom status bar. |
| [GNOME Terminal files](../dot_config/gnome-terminal) | `~/.config/gnome-terminal/` | Brogrammer profile export, `import-profile.sh`, and export and import notes. Import the profile into dconf separately. |
| [Kitty theme](../dot_config/kitty/themes/brogrammer-light.conf) | `~/.config/kitty/themes/brogrammer-light.conf` | Brogrammer Light theme. Select or include the theme separately. |
| [Xfce Terminal theme](../dot_config/xfce4/private_terminal/colorschemes/Brogrammer.theme) | `~/.config/xfce4/terminal/colorschemes/Brogrammer.theme` | Brogrammer theme. Select the theme in Xfce Terminal. |
| [Goneovim settings](../dot_config/goneovim/settings.toml) | `~/.config/goneovim/settings.toml` | Enables smooth cursor movement. |
| [herdr configuration](../dot_config/herdr/config.toml) | `~/.config/herdr/config.toml` | Disables onboarding and uses symbol status indicators. Pane arrangement bindings require the separately installed `crierr/herdr-arrange` plugin. |

tmux uses its default prefix.
After the prefix, `Shift+Left` and `Shift+Right` move the current window.
The backtick key opens a popup terminal with 80 percent width and height.

## mpv configuration

The [mpv directory](../dot_config/mpv) supplies playback settings, controls, scripts, and assets.
The configuration requires mpv 0.37.0 or newer.

| Source | Deployed path | Contents |
| --- | --- | --- |
| [Playback configuration](../dot_config/mpv/mpv.conf) | `~/.config/mpv/mpv.conf` | Defaults to the `hq` profile, with `gpu-next`, hardware decoding, interpolation, and automatic subtitle detection. |
| [Input configuration](../dot_config/mpv/input.conf) | `~/.config/mpv/input.conf` | Seek, speed, volume, fullscreen, video pan, rotation, and Anime4K controls. |
| [Scripts](../dot_config/mpv/exact_scripts) | `~/.config/mpv/scripts/` | autoload playlists, ModernZ controls, thumbfast previews, and the local fast-forward script. |
| [Script options](../dot_config/mpv/script-opts) | `~/.config/mpv/script-opts/` | autoload, fast-forward, ModernZ, and built-in controller settings. |
| [Fonts](../dot_config/mpv/fonts) | `~/.config/mpv/fonts/` | ModernZ icon font. |
| [Shaders](../dot_config/mpv/shaders) | `~/.config/mpv/shaders/` | Anime4K shaders referenced by the input configuration. |

The `exact_scripts` source makes the deployed scripts directory match the repository.
Chezmoi removes extra scripts from that directory when you apply the source.

`Ctrl+1` through `Ctrl+5` select Anime4K presets. `Ctrl+0` clears the shaders.
Hold `Insert` to activate the [fast-forward script](../dot_config/mpv/exact_scripts/fast-forward.lua).
Release `Insert` to restore the previous speed.
The [fast-forward options](../dot_config/mpv/script-opts/fast-forward.conf) cap the temporary speed at five times normal speed.
`q` saves playback state before exit. `Q` exits without that save command.

## Scripts

Chezmoi removes `executable_` from each script name and sets execute permissions.
The names below refer to scripts under `~/scripts` after deployment.

| Script source | Purpose | Requirements and behavior |
| --- | --- | --- |
| [compose_update.sh](../scripts/executable_compose_update.sh) | Update selected Docker Compose projects and purge Cloudflare caches after image changes. | Requires Bash, Docker Compose, curl, and GNU command-line tools. Reads `compose_update.conf` beside the script. `--all` skips selection. Stopped projects remain stopped. |
| [install_sandbox_playwright.sh](../scripts/executable_install_sandbox_playwright.sh) | Install the Playwright Chromium headless shell inside a container. | Accepts a container ID. Requires Docker and a container with npm and `/etc/apt/sources.list.d/debian.sources`. Changes container package sources to Tencent Cloud and downloads through npmmirror. |
| [nvim-gnome](../scripts/executable_nvim-gnome), [nvim-kitty](../scripts/executable_nvim-kitty), [nvim-xfce4](../scripts/executable_nvim-xfce4) | Run Neovim in the current terminal or a separate terminal window. | Requires `nvim.appimage` on `PATH`. `-g` opens the selected terminal. Each launcher requires [nvim-terminal](../scripts/executable_nvim-terminal) beside it. |
| [prepend-path](../scripts/executable_prepend-path) | Print a new `PATH` with the supplied directories first. | Requires Perl. Moves existing entries to the front. The caller must assign the printed value to `PATH`. |
| [qwen](../scripts/executable_qwen) | Start the Qwen Code Docker image. | Requires Docker. Pulls the `latest` image and mounts the current directory, `~/.qwen`, and `~/.skills`. |
| [video2av1](../scripts/executable_video2av1) | Convert a video to AV1 with AAC audio and write a size and bitrate report. | Requires Bash, FFmpeg with `libsvtav1`, ffprobe, awk, and GNU command-line tools. Accepts a path inside the current directory. `--self-test` checks the encoder and output shape. |

The repository does not include `compose_update.conf`.
The script header documents `COMPOSE_PROJECTS`, Cloudflare credentials, and `__SKIP__` for projects without cache purges.

The Playwright script installs browsers under `/opt/ms-playwright` inside the container.
Browser users must set `PLAYWRIGHT_BROWSERS_PATH=/opt/ms-playwright`.

The Neovim launchers accept a symbolic link named `nvim`.
With `-g`, piped input waits for EOF before the terminal opens.
The launcher loads that input into a read-only buffer.

`video2av1` keeps the first video stream and the first audio stream.
The output fits within 1440 by 810 pixels, or 810 by 1440 pixels for portrait video, at up to 30 fps.
The script writes `video2av1_output/<input-name>.av1.mp4` and a companion `.report.txt` file.
The encode uses a temporary part file, so a failed run leaves no partial output.
The script refuses an existing output file.

## Coding agent skills

Chezmoi deploys [dot_skills](../dot_skills) to `~/.skills`.
The installation guides describe the links that expose this directory to coding agents.
This table lists only skills stored in this repository.

The [README external resources](../README.md#external-resources) define which skills come from upstream repositories.
Local skills remain outside that dependency list.

| Skill | Purpose | Origin |
| --- | --- | --- |
| [cross-review](../dot_skills/cross-review/SKILL.md) | Use independent reviewers to audit code and agree on fixes. | Local |
| [devops-records](../dot_skills/devops-records/SKILL.md) | Read and update the `~/devops` operations records, and bootstrap them on a new machine. | Local |
| [purple-coding-style](../dot_skills/purple-coding-style/SKILL.md) | Apply coding conventions to source changes. | Local |
| [record-each-step](../dot_skills/record-each-step/SKILL.md) | Commit logical changes and manage later contributions when explicitly enabled. | Local |
| [session-performance-report](../dot_skills/session-performance-report/SKILL.md) | Measure local Qwen Code or Codex session logs. | Local |
| [stronger-skill](../dot_skills/stronger-skill/SKILL.md) | Create, review, and revise agent skills. | Local |
| [upgrade-dotfile-deps](../dot_skills/upgrade-dotfile-deps/SKILL.md) | Inspect and update dependencies listed in the README. | Local |
| [caveman](../dot_skills/caveman/SKILL.md) | Use terse replies while retaining technical facts. | External |
| [caveman-commit](../dot_skills/caveman-commit/SKILL.md) | Write concise Conventional Commits messages. | External |
| [convert-documents-to-markdown](../dot_skills/convert-documents-to-markdown/SKILL.md) | Convert office documents and PDFs to Markdown with anydoc. | External |
| [interface-kit](../dot_skills/interface-kit/SKILL.md) | Implement accessible interfaces, components, and animation. | External |
| [modern-web-guidance](../dot_skills/modern-web-guidance/SKILL.md) | Consult bundled guidance for current web development practices. | External |
| [ponytail](../dot_skills/ponytail/SKILL.md) | Make the smallest complete code change. | External |
| [ponytail-audit](../dot_skills/ponytail-audit/SKILL.md) | Audit a complete repository without changes. | External |
| [ponytail-debt](../dot_skills/ponytail-debt/SKILL.md) | List shortcut comments as a debt ledger. | External |
| [ponytail-gain](../dot_skills/ponytail-gain/SKILL.md) | Show published benchmark savings. | External |
| [ponytail-help](../dot_skills/ponytail-help/SKILL.md) | Show the ponytail command reference. | External |
| [ponytail-review](../dot_skills/ponytail-review/SKILL.md) | Review a change for correctness, safety, performance, and unnecessary code. | External |
| [show-me](../dot_skills/show-me/SKILL.md) | Explain a topic with diagrams and focused visual artifacts. | External |
| [write-docs](../dot_skills/write-docs/SKILL.md) | Write and revise technical documents. | External |

## Inventory source

Use this command from the repository root to list the tracked configurations, scripts, and skill entry points:

```bash
git ls-files dot_config dot_vim dot_vimrc dot_ctags dot_tmux.conf scripts 'dot_skills/*/SKILL.md'
```

The [external resource list](../README.md#external-resources) records upstream sources for bundled dependencies.
