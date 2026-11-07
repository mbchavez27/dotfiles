# kde/

Versioned Plasma theme state for Fedora. macOS never reads this directory.

## Layout

```
themes/<slug>/
  theme.json              # every value the installer applies
  plasma/look-and-feel/   # global theme + splash screen
  plasma/desktoptheme/    # Plasma style
  aurorae/                # window decorations (1x, 1.25x, 1.5x)
  color-schemes/          # .colors file
  kvantum/<pack>/         # Kvantum theme pack
  sddm/<theme>/           # login theme, including theme.conf.user
shared/
  gtk-3.0/ gtk-4.0/       # KDE-synced GTK settings and colours
  xsettingsd/             # icon theme, cursor theme, fonts for GTK
  panels/                 # plasmashellrc + appletsrc (hardware-specific)
  plasmoids/              # third-party widgets
  wallpapers/             # wallpapers referenced by the panel layout
```

Icons and cursors are not stored here. Their repositories and pinned commits
live in `theme.json` under `sources`, because the WhiteSur set is ~180 MB.

## Commands

```bash
./capture-kde.sh --check                 # live session vs. tracked theme
./capture-kde.sh --vendor                # refresh the current theme
./capture-kde.sh --slug NAME --vendor    # snapshot a new theme
./install/kde.sh --list
./install/kde.sh --theme <slug> --dry-run
./install/kde.sh --theme <slug>
```

Both scripts refuse to run outside Linux/Fedora/KDE. `install/kde.sh` refuses
on macOS so a shared checkout cannot modify the macOS setup.

## theme.json

| Key | Meaning |
|---|---|
| `plasma.lookAndFeel` | Global theme package id |
| `plasma.desktopTheme` | Plasma style name |
| `plasma.colorScheme` | Colour scheme file name (without `.colors`) |
| `plasma.splash` | Splash theme id |
| `decoration.library` / `.theme` / `.borderSize` | Aurorae decoration |
| `qt.widgetStyle` / `.kvantumTheme` | Qt style and Kvantum pack name |
| `icons.theme` | Icon theme |
| `cursor.theme` / `.size` | Cursor theme and size |
| `sddm.theme` / `.dir` | SDDM theme name and vendored path |
| `fonts.ui` / `.fixed` / `.terminal` | Fonts to verify with `fc-match` |
| `appearance.*` | Accent, Xft, contrast, full KDE font strings |
| `extras.kwinPlugins` | Blur/rounded-corner KWin keys, if any |
| `sources.*` | Pinned upstream repos + commits |

`sourceHome` records the machine the theme was captured on; the installer
rewrites that prefix to `$HOME` when restoring panel files.

## Capturing after a change

1. Apply the change in System Settings.
2. `./capture-kde.sh --vendor`
3. `./capture-kde.sh --check` (should pass)
4. `git add kde && git commit -m "chore(kde): refresh theme snapshot"`

`capture-kde.sh` preserves the existing `sources` block, so pins survive a
re-capture. It does not overwrite `theme.json` without confirmation unless
`--force` is given.

## Sizes

Current snapshot: ~6.8 MB for `macsonoma-dark`, ~6.2 MB for `shared`.
Adding themes is cheap; adding icon packs is not — keep those as pinned
clones.
