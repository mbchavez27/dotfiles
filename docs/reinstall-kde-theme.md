# Reinstalling the KDE theme

Restores the Plasma visual stack captured in [`kde/`](../kde/) on a fresh
Fedora KDE install, after a reformat, or on another Fedora machine.

This document covers the theme only. Shell, terminal, editor, and AI tooling
are handled by the main [README](../README.md); macOS is untouched by
everything under `kde/`.

## What this restores

Captured theme: **`macsonoma-dark`** (MacSonoma-Dark + WhiteSur).

| Layer | Applied value |
|---|---|
| Global theme / look-and-feel | `com.github.vinceliuice.MacSonoma-Dark` |
| Plasma style | `MacSonoma-Dark` |
| Window decoration | Aurorae `__aurorae__svg__MacSonoma-Dark`, border `Tiny` |
| Colour scheme | `MacSonomaDark` |
| Icons | `WhiteSur-dark` |
| Cursor | `WhiteSur-cursors`, 24 px |
| Qt widget style | `kvantum-dark` → Kvantum `MacSonomaDark` |
| Splash | `com.github.vinceliuice.MacSonoma-Dark` |
| SDDM | `WhiteSur-dark` |
| GTK | Breeze + KDE-synced `colors.css`, WhiteSur icons/cursor |
| UI font | `SF Pro Rounded` 10 pt (bold for menus/toolbars, 9 pt toolbar, 8 pt small) |
| Fixed font | `SF Pro Rounded` 10 pt bold |
| Terminal font | `MesloLGS NF` |
| Accent | `233,61,88` |
| Wallpapers | 4 images in `~/Pictures/Wallpapers` |
| Widgets | `Music.Waves`, `KdeControlStation`, `Better Inline Clock` |

Source of truth: `kde/themes/macsonoma-dark/theme.json`. Assets are vendored
next to it; icons and cursors are cloned from pinned upstream commits.

## Requirements

- Fedora KDE, Plasma 6.x, inside a KDE session (Wayland or X11)
- This repo cloned to `~/dotfiles` (or anywhere — the scripts resolve it)
- `git`, `python3`, `kwriteconfig6`, `kreadconfig6`, `rsync`
- Network for the pinned icon/cursor clones
- `sudo` only when using `--sddm`

The installers refuse to run on macOS or outside a KDE session, so a dual-boot
or shared checkout cannot damage the macOS setup.

## One-command path

```bash
cd ~/dotfiles

# preview first
./install/kde.sh --theme macsonoma-dark --dry-run

# apply
./install/kde.sh --theme macsonoma-dark
```

Then **log out and back in**. KWin, Kvantum, GTK, and SDDM only pick everything
up on a new session.

Full restore, including panels and the login screen:

```bash
./install/kde.sh --theme macsonoma-dark --panels --sddm
```

### Options

| Flag | Effect |
|---|---|
| `--theme NAME` | Theme slug under `kde/themes/` (default `macsonoma-dark`) |
| `--list` | List captured themes |
| `--dry-run` | Print every action, change nothing |
| `--force` | Replace existing theme files without prompting |
| `--panels` | Restore the panel/applet layout (stops plasmashell briefly) |
| `--sddm` | Install the SDDM theme and drop-in (needs sudo) |
| `--no-wallpapers` | Skip `~/Pictures/Wallpapers` |
| `--no-plasmoids` | Skip third-party Plasma widgets |
| `--skip-icons` | Keep the current icon theme |
| `--skip-cursor` | Keep the current cursor theme |

Existing files and theme directories are moved to
`~/.dotfiles-backup/<timestamp>/`; nothing is deleted.

## What lives where

```
kde/
  themes/macsonoma-dark/
    theme.json                     # every applied value
    plasma/look-and-feel/          # global theme + splash
    plasma/desktoptheme/           # Plasma style
    aurorae/                       # window decorations (1x, 1.25x, 1.5x)
    color-schemes/                 # MacSonomaDark.colors
    kvantum/MacSonoma/             # Kvantum pack (applied name: MacSonomaDark)
    sddm/WhiteSur-dark/            # login theme incl. theme.conf.user
  shared/
    gtk-3.0/ gtk-4.0/              # KDE-synced GTK settings and colours
    xsettingsd/xsettingsd.conf
    panels/                        # plasmashellrc + appletsrc
    plasmoids/                     # Music.Waves, KdeControlStation, clock
    wallpapers/                    # the four captured wallpapers
```

Icons and cursors are **not** vendored: the WhiteSur set is ~180 MB. Their
repos and commits are pinned in `theme.json` under `sources`.

## Step-by-step path

Use this if the one-command script fails or you want to understand each layer.

### 1. Packages

```bash
sudo dnf install -y kvantum qt6-qtmultimedia
```

`kvantum` provides the Qt style; `qt6-qtmultimedia` is needed by `Music.Waves`.

### 2. Theme assets

```bash
cp -a kde/themes/macsonoma-dark/plasma/look-and-feel/*  ~/.local/share/plasma/look-and-feel/
cp -a kde/themes/macsonoma-dark/plasma/desktoptheme/*   ~/.local/share/plasma/desktoptheme/
cp -a kde/themes/macsonoma-dark/aurorae/*               ~/.local/share/aurorae/themes/
cp -a kde/themes/macsonoma-dark/color-schemes/*.colors  ~/.local/share/color-schemes/
cp -a kde/themes/macsonoma-dark/kvantum/*               ~/.config/Kvantum/
```

### 3. Icons and cursors

```bash
tmp="$(mktemp -d)"
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git "$tmp/icons"
git -C "$tmp/icons" checkout 73d8040da51a9ed74e47c7366e7e9ff437601a5c
(cd "$tmp/icons" && ./install.sh)

git clone https://github.com/vinceliuice/WhiteSur-cursors.git "$tmp/cursors"
git -C "$tmp/cursors" checkout e190baf618ed95ee217d2fd45589bd309b37672b
(cd "$tmp/cursors" && ./install.sh)
```

### 4. GTK and xsettingsd

```bash
cp -a kde/shared/gtk-3.0/. ~/.config/gtk-3.0/
cp -a kde/shared/gtk-4.0/. ~/.config/gtk-4.0/
cp -a kde/shared/xsettingsd/xsettingsd.conf ~/.config/xsettingsd/xsettingsd.conf
gtk-update-icon-cache -f -t ~/.local/share/icons/WhiteSur-dark
```

### 5. Widgets and wallpapers

```bash
cp -a kde/shared/plasmoids/. ~/.local/share/plasma/plasmoids/
mkdir -p ~/Pictures/Wallpapers
cp -a kde/shared/wallpapers/. ~/Pictures/Wallpapers/
```

### 6. Config keys

```bash
kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage com.github.vinceliuice.MacSonoma-Dark
kwriteconfig6 --file kdeglobals --group General --key ColorScheme MacSonomaDark
kwriteconfig6 --file kdeglobals --group Icons --key Theme WhiteSur-dark
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum-dark
kwriteconfig6 --file kdeglobals --group General --key font 'SF Pro Rounded,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1'
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae.v2
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme __aurorae__svg__MacSonoma-Dark
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key BorderSize Tiny
kwriteconfig6 --file ksplashrc --group KSplash --key Engine KSplashQML
kwriteconfig6 --file ksplashrc --group KSplash --key Theme com.github.vinceliuice.MacSonoma-Dark
kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme WhiteSur-cursors
kwriteconfig6 --file kcminputrc --group Mouse --key cursorSize 24
kwriteconfig6 --file ~/.config/Kvantum/kvantum.kvconfig --group General --key theme MacSonomaDark
```

The installer writes the full set from `theme.json`, including fonts, accent,
Xft settings, and the Ghostty terminal entry.

### 7. Apply live

```bash
plasma-apply-desktoptheme MacSonoma-Dark
plasma-apply-colorscheme MacSonomaDark
plasma-apply-cursortheme WhiteSur-cursors
kbuildsycoca6 --noincremental
```

### 8. Login screen (optional)

```bash
sudo mkdir -p /usr/share/sddm/themes
sudo cp -a kde/themes/macsonoma-dark/sddm/WhiteSur-dark /usr/share/sddm/themes/
printf '[Theme]\nCurrent=WhiteSur-dark\n' | sudo tee /etc/sddm.conf.d/zz-kde-theme.conf
```

The `zz-` prefix matters: Fedora writes `/etc/sddm.conf.d/kde_settings.conf`,
and SDDM reads drop-ins in lexical order, so a file sorting before
`kde_settings.conf` would be overridden.

### 9. Panels (optional)

```bash
systemctl --user stop plasma-plasmashell.service
sed "s|/home/mbchavez|$HOME|g" \
  kde/shared/panels/plasma-org.kde.plasma.desktop-appletsrc \
  > ~/.config/plasma-org.kde.plasma.desktop-appletsrc
sed "s|/home/mbchavez|$HOME|g" \
  kde/shared/panels/plasmashellrc > ~/.config/plasmashellrc
systemctl --user start plasma-plasmashell.service
```

`lastScreen` indexes are hardware-specific. On a different monitor layout the
panels can land on the wrong output; drag them once and re-capture.

## Fonts

| Font | Used for | Where it comes from |
|---|---|---|
| `SF Pro Rounded` | UI + fixed | Apple's SF Pro download (`~/.local/share/fonts/sf-pro`) |
| `MesloLGS NF` | Ghostty / p10k | `install/fedora.sh` downloads it |

SF Pro is Apple-licensed and intentionally not committed. Install it manually:

1. Download SF Pro from <https://developer.apple.com/fonts/>.
2. Unpack the `.otf` files into `~/.local/share/fonts/sf-pro`.
3. `fc-cache -f`.

Check:

```bash
fc-match -f '%{family[0]}\n' 'SF Pro Rounded'
fc-match -f '%{family[0]}\n' 'MesloLGS NF'
```

If SF Pro is missing, KDE falls back to a system sans and the layout shifts.
The installer prints `MISSING:` for each font it cannot resolve but keeps
going.

## Verification

```bash
# every layer at once (compares the live session to theme.json)
./capture-kde.sh --check

# individual values
kreadconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage
kreadconfig6 --file kdeglobals --group Icons --key Theme
kreadconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme
kreadconfig6 --file ksplashrc --group KSplash --key Theme
kreadconfig6 --file kcminputrc --group Mouse --key cursorTheme
kreadconfig6 --file ~/.config/Kvantum/kvantum.kvconfig --group General --key theme

# assets and SDDM
test -d ~/.local/share/icons/WhiteSur-dark && echo icons ok
test -d ~/.local/share/plasma/look-and-feel/com.github.vinceliuice.MacSonoma-Dark && echo lookfeel ok
grep -H Current /etc/sddm.conf.d/zz-kde-theme.conf
```

`./capture-kde.sh --check` exits 1 and prints a diff when the live session
drifts from the tracked manifest.

## Troubleshooting

**Icons still look like Breeze.** `kbuildsycoca6 --noincremental`, then log
out. The icon theme also lives in `~/.config/kdedefaults/kdeglobals`; if the
KCM keeps reverting, set it there too:

```bash
kwriteconfig6 --file kdedefaults/kdeglobals --group Icons --key Theme WhiteSur-dark
```

**Cursor does not change.** `~/.config/kcminputrc` is often empty on a fresh
install, which is why the setting appears to be ignored. Check both:

```bash
kreadconfig6 --file kcminputrc --group Mouse --key cursorTheme
kreadconfig6 --file kdedefaults/kcminputrc --group Mouse --key cursorTheme
```

Re-apply with `plasma-apply-cursortheme WhiteSur-cursors` and log out.

**Kvantum is ignored.** Confirm `[KDE] widgetStyle=kvantum-dark` and
`~/.config/Kvantum/kvantum.kvconfig` → `[General] theme=MacSonomaDark`. Restart
the Qt app; `kvantummanager` can also apply the pack interactively.

**SDDM still shows Breeze.** Check that the theme directory is readable,
`/usr/share/sddm/themes/WhiteSur-dark/Main.qml` exists, and that
`/etc/sddm.conf.d/zz-kde-theme.conf` is the last drop-in alphabetically.

**Panel layout is on the wrong screen.** `lastScreen` values are indexes from
the source machine. Drag the panels to the right output once, then run
`./capture-kde.sh --panels` (or `--vendor`) and commit.

**GTK apps ignore the colours.** They are generated by `kde-gtk-config` into
`~/.config/gtk-3.0/colors.css`; changing the Plasma colour scheme regenerates
them. Log out if a running app keeps the old values.

**Global menu does not show GTK app menus.** `~/.gtkrc-2.0` references
`appmenu-gtk-module`, which is not installed by default:
`sudo dnf install appmenu-gtk-module`.

**Fonts render as boxes.** See [Fonts](#fonts).

## Rollback

Backups: `~/.dotfiles-backup/<timestamp>/`.

```bash
# switch back to another captured theme
./install/kde.sh --theme macsonoma-dark

# remove the SDDM override
sudo rm /etc/sddm.conf.d/zz-kde-theme.conf

# restore a backed-up config file
cp -a ~/.dotfiles-backup/<timestamp>/.config/kdeglobals ~/.config/kdeglobals
```

## Switching themes

The theme layer is data-driven. Each theme is a directory with a `theme.json`
manifest; the installer only reads manifest keys. To move from MacSonoma to
macOS Tahoe (`vinceliuice/MacTahoe-kde`):

1. Install the upstream theme and apply it in System Settings: `MacTahoe-kde`,
   `MacTahoe-icon-theme` (icons + `cursors/`), and its SDDM theme. Tune panels,
   blur, and corner radius until it matches what you want.
2. Capture the live result:

   ```bash
   ./capture-kde.sh --slug mactahoe-dark --vendor
   ```

3. Review `kde/themes/mactahoe-dark/theme.json`. A new slug has an empty
   `sources` object — fill in the repos and commits so a fresh machine can
   clone the icons and cursors:

   ```json
   "sources": {
     "theme":  { "repo": "https://github.com/vinceliuice/MacTahoe-kde.git", "commit": "<sha>" },
     "icons":  { "repo": "https://github.com/vinceliuice/MacTahoe-icon-theme.git", "commit": "<sha>", "install": "./install.sh" },
     "cursor": { "repo": "https://github.com/vinceliuice/MacTahoe-icon-theme.git", "commit": "<sha>", "subpath": "cursors", "install": "./install.sh" },
     "sddm":   { "repo": "https://github.com/vinceliuice/MacTahoe-kde.git", "commit": "<sha>", "subpath": "sddm" }
   }
   ```

4. Test and commit:

   ```bash
   ./install/kde.sh --theme mactahoe-dark --dry-run
   git add kde/themes/mactahoe-dark && git commit -m "feat(kde): add mactahoe-dark theme"
   ```

Both themes coexist; `./install/kde.sh --theme macsonoma-dark` is the rollback.

Tahoe extras such as `kwin-effects-forceblur` and a 24 px corner radius are
not automated yet. They are captured under `extras.kwinPlugins` when present;
install the KWin effect separately.

## Scope

Not covered here:

- enabling repos/COPRs
- RPM application packages and Flatpaks
- Rust, Node, SDKMAN, Docker, NVIDIA
- shell, terminal, editor, and AI configuration (see the main README)
- macOS

Reference environment: Fedora 44, Plasma 6.7.5, KWin 6.7.5, Wayland, SDDM.
