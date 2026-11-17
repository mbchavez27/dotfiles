# What the installers put on disk

Every file and folder that `install/macos.sh`, `install/fedora.sh` and
`install/kde.sh` create, per OS, with approximate sizes. To remove them, run
`./install/uninstall.sh`. It asks before each group, and `DRY_RUN=1` previews
without changing anything.

Sizes are measured on an Apple-silicon Mac unless marked "est.".

## Both OSes (same paths)

| What | Path | Size | Created by |
|---|---|---|---|
| Config symlinks | `~/.zshrc`, `~/.p10k.zsh`, `~/.bashrc`, `~/.bash_profile`, `~/.config/nvim`, `~/.config/ghostty/config`, `~/.config/opencode`, `~/.claude/skills`, `~/.claude/settings.json`, `~/.gemini/antigravity-cli/skills` | 0 (links into `~/dotfiles`) | `run_symlinks` |
| Backups of replaced configs | `~/.dotfiles-backup/<timestamp>/` | KBs | `backup_dest` |
| Oh My Zsh + powerlevel10k + zsh-autosuggestions + zsh-syntax-highlighting | `~/.oh-my-zsh/` (themes and plugins under `custom/`) | ~95 MB | `install_omz` |
| powerlevel10k cache | `~/.cache/p10k-*`, `~/.cache/gitstatus/` | ~10 MB est. | first zsh start |
| nvim plugins (lazy.nvim) | `~/.local/share/nvim/lazy/` | 174 MB | first `nvim` launch |
| nvim LSP servers, formatters, debuggers (Mason) | `~/.local/share/nvim/mason/` | 882 MB: TS/web 240, Markdown/SQL/YAML/TOML 140, Docker 122 (hadolint alone 113), Go 115, Svelte 65, Java 65, Python 56, CMake 38 | first `nvim` launch |
| nvim Python host (pynvim, jupyter_client, nbformat) | `~/.local/share/nvim/python/` | 17 MB | `setup_nvim_python` |
| Molten remote-plugin manifest | `~/.local/share/nvim/rplugin.vim` | KBs | `:UpdateRemotePlugins` |
| Discord presence server (cord.nvim) | `~/.local/share/nvim/cord/` | <1 MB | `:Cord update` |
| VisiData (`vd`) | `~/.local/share/uv/tools/visidata/`, `~/.local/bin/vd`, `~/.visidata/`, `~/.visidatarc` | 41 MB (+127 MB parquet/pyarrow, +1.4 MB xlsx/openpyxl) | `setup_visidata` (`uv tool install`) |
| uv cache (`uvx jupyterlab`, project installs) | `~/.cache/uv/` | varies; `uv cache clean` | uv |
| nvim state (undo, shada, sessions, logs) | `~/.local/state/nvim/` | <1 MB | nvim |
| nvim cache | `~/.cache/nvim/` | ~5 MB | nvim |

Skipped Mason downloads (see `nvim/lua/plugins/lang.lua`): `clangd` (uses the
system `/usr/bin/clangd`) and `codelldb` (C/C++/Rust debugger, ~120 MB est.).
Rust's `rust-analyzer` comes from rustup (`~/.rustup/`), not Mason.

Your own repo clone (`~/dotfiles`) is never deleted by the uninstaller.

## macOS

| What | Path | Size | Created by |
|---|---|---|---|
| Homebrew itself (only if it was missing) | `/opt/homebrew/` (Intel: `/usr/local/`) | 500 MB+ | `macos.sh` |
| neovim | `/opt/homebrew/Cellar/neovim/` | 33 MB | `brew install` |
| lazygit | `/opt/homebrew/Cellar/lazygit/` | 38 MB | `brew install` |
| ripgrep, fd (only if missing) | `/opt/homebrew/Cellar/{ripgrep,fd}/` | ~10 MB | `brew install` |
| ImageMagick + dependencies (optional prompt) | `/opt/homebrew/Cellar/{imagemagick,aom,x265,libheif,libde265,libvmaf,libtool,m4}/` | 88 MB | `brew install` |
| zsh, git, curl (kept by the uninstaller) | `/opt/homebrew/Cellar/{zsh,git,curl}/` | 160 MB | `brew install` |
| Ghostty app | `/Applications/Ghostty.app` (record in `/opt/homebrew/Caskroom/ghostty`) | 67 MB | `brew install --cask` |
| Ghostty native config/state | `~/Library/Application Support/com.mitchellh.ghostty/` | KBs | Ghostty |
| MesloLGS NF font | `~/Library/Fonts/MesloLGS NF *.ttf` | ~10 MB | `font-meslo-for-powerlevel10k` cask |
| Homebrew download cache | `~/Library/Caches/Homebrew/` | varies | brew (cleared by `brew cleanup`) |
| Jupyter kernels you register | `~/Library/Jupyter/kernels/<name>/` | KBs each | `ipykernel install --user` |

## Fedora

| What | Path | Size | Created by |
|---|---|---|---|
| zsh, neovim, git, curl | `/usr/bin`, `/usr/share` (RPMs) | ~60 MB est. | `dnf install` |
| ripgrep, fd-find, uv (only if missing) | `/usr/bin` (RPMs) | ~50 MB est. | `dnf install` |
| ImageMagick (optional prompt) | `/usr/bin`, `/usr/lib64` (RPMs) | ~60 MB est. | `dnf install` |
| lazygit + COPR repo | `/usr/bin/lazygit`, `/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:atim:lazygit.repo` | ~40 MB est. | `dnf copr enable` |
| Ghostty + COPR repo | `/usr/bin/ghostty`, `/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:scottames:ghostty.repo` | ~70 MB est. | `dnf copr enable` |
| MesloLGS NF font | `~/.local/share/fonts/meslolgs-nf/` | ~10 MB | `fedora.sh` |
| dnf cache | `/var/cache/dnf/` | varies | dnf (`sudo dnf clean all`) |
| Jupyter kernels you register | `~/.local/share/jupyter/kernels/<name>/` | KBs each | `ipykernel install --user` |

### KDE Plasma theme (`install/kde.sh`, Fedora KDE only)

| What | Path |
|---|---|
| Global theme | `~/.local/share/plasma/look-and-feel/com.github.vinceliuice.MacSonoma-Dark/` |
| Plasma style | `~/.local/share/plasma/desktoptheme/MacSonoma-Dark/` |
| Window decorations | `~/.local/share/aurorae/themes/MacSonoma-Dark*/` |
| Colour scheme | `~/.local/share/color-schemes/MacSonomaDark.colors` |
| Kvantum theme | `~/.config/Kvantum/MacSonoma/`, `~/.config/Kvantum/kvantum.kvconfig` |
| Icons, cursors | `~/.local/share/icons/WhiteSur*/`, `~/.local/share/icons/WhiteSur-cursors/` |
| Plasmoids | `~/.local/share/plasma/plasmoids/{KdeControlStation,Music.Waves,org.kde.plasma.betterinlineclock}/` |
| Wallpapers | `~/Pictures/Wallpapers/Wal*paper_*.jpg` |
| GTK sync | `~/.config/gtk-3.0/`, `~/.config/gtk-4.0/` (`gtk.css`, `colors.css`, `window_decorations.css`, `assets/`) |
| xsettingsd | `~/.config/xsettingsd/xsettingsd.conf` |
| Panel layout (edited in place) | `~/.config/plasma-org.kde.plasma.desktop-appletsrc`, `~/.config/plasmashellrc` |
| Settings keys (edited in place) | `~/.config/kdeglobals`, `kwinrc`, `ksplashrc`, `kcminputrc` |
| SDDM login theme (sudo) | `/usr/share/sddm/themes/WhiteSur-dark/`, `/etc/sddm.conf.d/zz-kde-theme.conf` |
| RPMs | `kvantum`, `qt6-qtmultimedia` |

The uninstaller removes the copied theme files. It does **not** revert keys that
were edited in place (kdeglobals, kwinrc, panels). Switch back to Breeze in
System Settings → Global Theme before or after running it.

## Not installed by the scripts

You install these yourself (README Step 3), so the uninstaller leaves them alone:
opencode, the Claude Code CLI (`~/.local/bin/claude`, `~/.claude/`),
Antigravity CLI (`~/.local/bin/agy`, `~/.gemini/`), nvm/Node (`~/.nvm/`),
uv on macOS (`~/.local/bin/uv`, cache `~/.cache/uv/`), Rust (`~/.cargo/`,
`~/.rustup/`), SDKMAN (`~/.sdkman/`), VS Code and Docker.

## Removing things

```bash
DRY_RUN=1 ./install/uninstall.sh   # preview: lists every path with its size
./install/uninstall.sh             # asks per group / per package
```

To shrink nvim without uninstalling it, remove an extra in `:LazyExtras`
(e.g. `lang.java`), then run `:Lazy clean` and `:Mason` → `X` on the unused server.
