#!/usr/bin/env bash
# Apply a captured KDE/Plasma theme from kde/themes/<slug>/ on Fedora.
#
# Fedora + KDE only. This script is additive: it never edits the shared shell,
# editor, or macOS files, and it never symlinks KDE-managed config files.
set -euo pipefail

. "$(cd "$(dirname "$0")" && pwd)/common.sh"

THEME=""
DRY=0
FORCE=0
PANELS=0
SDDM=0
INSTALL_WALLPAPERS=1
INSTALL_PLASMOIDS=1
SKIP_ICONS=0
SKIP_CURSOR=0
LIST=0

usage() {
  cat <<'EOF'
Usage: ./install/kde.sh [OPTIONS]

Apply a theme captured by ./capture-kde.sh.

OPTIONS
  --theme NAME        Theme slug under kde/themes/ (default: macsonoma-dark)
  --list              List captured themes and exit
  --dry-run           Print actions without changing anything
  --force             Replace existing theme files without prompting
  --panels            Restore the captured Plasma panel layout (stops
                      plasmashell while copying; screen indexes are
                      hardware-specific)
  --sddm              Install the captured SDDM login theme (needs sudo)
  --no-wallpapers     Skip ~/Pictures/Wallpapers
  --no-plasmoids      Skip third-party Plasma widgets
  --skip-icons        Keep the current icon theme
  --skip-cursor       Keep the current cursor theme
  -h, --help          Show this help

See docs/reinstall-kde-theme.md.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --theme) THEME="${2:?--theme needs a value}"; shift 2 ;;
    --list) LIST=1; shift ;;
    --dry-run) DRY=1; shift ;;
    --force) FORCE=1; shift ;;
    --panels) PANELS=1; shift ;;
    --sddm) SDDM=1; shift ;;
    --no-wallpapers) INSTALL_WALLPAPERS=0; shift ;;
    --no-plasmoids) INSTALL_PLASMOIDS=0; shift ;;
    --skip-icons) SKIP_ICONS=1; shift ;;
    --skip-cursor) SKIP_CURSOR=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [ "$LIST" -eq 1 ]; then
  found=0
  for manifest in "$DOTFILES"/kde/themes/*/theme.json; do
    [ -f "$manifest" ] || continue
    python3 - "$manifest" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    data = json.load(handle)
print(f"{data.get('id', '?')}\t{data.get('label', '')}")
PY
    found=1
  done
  [ "$found" -eq 1 ] || echo "No captured themes in $DOTFILES/kde/themes"
  exit 0
fi

# --- Platform guards -------------------------------------------------------
if [ "$(uname -s)" != "Linux" ]; then
  echo "KDE setup is Fedora/Linux only. On macOS use install/macos.sh." >&2
  exit 1
fi

if [ ! -f /etc/os-release ]; then
  echo "Cannot detect the distribution (/etc/os-release missing)." >&2
  exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release
if [ "${ID:-}" != "fedora" ]; then
  echo "This is ${ID:-unknown}, not Fedora. Nothing to do here." >&2
  exit 1
fi

case "${XDG_CURRENT_DESKTOP:-}" in
  *KDE*) ;;
  *) echo "Not a KDE Plasma session (XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-unset})." >&2; exit 1 ;;
esac

for bin in python3 kwriteconfig6 kreadconfig6; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "Missing dependency: $bin" >&2
    exit 1
  fi
done

# --- Theme selection -------------------------------------------------------
if [ -z "$THEME" ]; then
  if [ -d "$DOTFILES/kde/themes/macsonoma-dark" ]; then
    THEME=macsonoma-dark
  else
    THEME="$(find "$DOTFILES/kde/themes" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort | head -n1)"
  fi
fi

THEME_DIR="$DOTFILES/kde/themes/$THEME"
MANIFEST="$THEME_DIR/theme.json"
SHARED="$DOTFILES/kde/shared"

if [ -z "$THEME" ] || [ ! -f "$MANIFEST" ]; then
  echo "No captured theme at $MANIFEST" >&2
  echo "Run ./capture-kde.sh --vendor first, or see ./install/kde.sh --list" >&2
  exit 1
fi

mget() {
  python3 - "$MANIFEST" "$1" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    node = json.load(handle)
for part in sys.argv[2].split("."):
    if isinstance(node, dict) and part in node:
        node = node[part]
    else:
        node = ""
        break
if node is None:
    node = ""
if isinstance(node, (dict, list)):
    print(json.dumps(node))
else:
    print(node)
PY
}

look_and_feel="$(mget plasma.lookAndFeel)"
desktop_theme="$(mget plasma.desktopTheme)"
color_scheme="$(mget plasma.colorScheme)"
splash_theme="$(mget plasma.splash)"
decoration_library="$(mget decoration.library)"
decoration_theme="$(mget decoration.theme)"
decoration_border="$(mget decoration.borderSize)"
widget_style="$(mget qt.widgetStyle)"
kvantum_theme="$(mget qt.kvantumTheme)"
icon_theme="$(mget icons.theme)"
cursor_theme="$(mget cursor.theme)"
cursor_size="$(mget cursor.size)"
sddm_theme="$(mget sddm.theme)"
sddm_dir="$THEME_DIR/$(mget sddm.dir)"
source_home="$(mget sourceHome)"
terminal_font="$(mget fonts.terminal)"

echo "Theme:      $THEME ($(mget label))"
echo "Captured:   $(mget capturedAt)"
echo "Source host: $source_home"
echo ""

# --- Helpers ---------------------------------------------------------------
run() {
  if [ "$DRY" -eq 1 ]; then
    printf '  + %s\n' "$*"
    return 0
  fi
  "$@"
}

run_shell() {
  if [ "$DRY" -eq 1 ]; then
    printf '  + %s\n' "$*"
    return 0
  fi
  bash -c "$*"
}

backed_up=""
backup_file() {
  local src="$1" rel dest
  [ -e "$src" ] || return 0
  case " $backed_up " in *" $src "*) return 0 ;; esac
  backed_up="$backed_up $src"
  rel="${src#"$HOME"/}"
  dest="$BACKUP_DIR/$rel"
  run mkdir -p "$(dirname "$dest")"
  run cp -a "$src" "$dest"
  if [ "$DRY" -eq 1 ]; then
    echo "  would back up: $src"
  else
    echo "  backed up: $src"
  fi
}

install_file() {
  local src="$1" dest="$2"
  [ -f "$src" ] || return 0
  if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
    echo "  unchanged: $dest"
    return 0
  fi
  backup_file "$dest"
  run mkdir -p "$(dirname "$dest")"
  run cp -a "$src" "$dest"
  if [ "$DRY" -eq 1 ]; then
    echo "  would install: $dest"
  else
    echo "  installed: $dest"
  fi
}

install_dir() {
  local src="$1" dest="$2"
  [ -d "$src" ] || return 0
  if [ -d "$dest" ] && diff -rq "$src" "$dest" >/dev/null 2>&1; then
    echo "  unchanged: $dest"
    return 0
  fi
  if [ -e "$dest" ]; then
    if [ "$DRY" -eq 1 ]; then
      echo "  would replace: $dest"
    elif [ "$FORCE" -eq 1 ] || confirm "Replace $dest? (original moved to backup)"; then
      run backup_dest "$dest"
    else
      echo "  skipped:   $dest"
      return 0
    fi
  fi
  run mkdir -p "$(dirname "$dest")"
  run cp -a "$src" "$dest"
  echo "  installed: $dest"
}

apply_key() {
  local file="$1" group="$2" key="$3" value="$4"
  [ -n "$value" ] || return 0
  run kwriteconfig6 --file "$file" --group "$group" --key "$key" "$value"
}

check_font() {
  local wanted="$1" actual
  actual="$(fc-match -f '%{family[0]}' "$wanted" 2>/dev/null || true)"
  if printf '%s' "$actual" | grep -qiF "$wanted"; then
    echo "  font ok:   $wanted"
  else
    echo "  MISSING:   $wanted (fontconfig resolves to '$actual')" >&2
  fi
}

clone_source() {
  local label="$1" repo="$2" commit="$3" subpath="$4" install_cmd="$5"
  local tmp workdir
  if [ -z "$repo" ]; then
    echo "  no source for $label — skipping" >&2
    return 0
  fi
  tmp="$(mktemp -d)"
  echo "  cloning:   $label @ ${commit:-HEAD}"
  run git clone --quiet --filter=blob:none "$repo" "$tmp/src"
  if [ -n "$commit" ]; then
    run git -C "$tmp/src" checkout --quiet "$commit"
  fi
  workdir="$tmp/src"
  [ -n "$subpath" ] && workdir="$workdir/$subpath"
  echo "  running:   ${install_cmd:-./install.sh} ($workdir)"
  run_shell "cd '$workdir' && ${install_cmd:-./install.sh}"
  rm -r "$tmp"
}

ensure_rpm() {
  local pkg="$1"
  if rpm -q "$pkg" >/dev/null 2>&1; then
    echo "  present:   $pkg"
    return 0
  fi
  if [ "$DRY" -eq 1 ]; then
    echo "  + sudo dnf install -y $pkg"
  elif confirm "Install missing package $pkg?"; then
    sudo dnf install -y "$pkg"
  else
    echo "  skipped:   $pkg" >&2
  fi
}

# --- Dependencies ----------------------------------------------------------
echo "Dependencies:"
ensure_rpm kvantum
ensure_rpm qt6-qtmultimedia

# --- Theme assets ----------------------------------------------------------
echo "Theme assets:"
for dir in "$THEME_DIR"/plasma/look-and-feel/*; do
  [ -d "$dir" ] || continue
  install_dir "$dir" "$HOME/.local/share/plasma/look-and-feel/$(basename "$dir")"
done
for dir in "$THEME_DIR"/plasma/desktoptheme/*; do
  [ -d "$dir" ] || continue
  install_dir "$dir" "$HOME/.local/share/plasma/desktoptheme/$(basename "$dir")"
done
for dir in "$THEME_DIR"/aurorae/*; do
  [ -d "$dir" ] || continue
  install_dir "$dir" "$HOME/.local/share/aurorae/themes/$(basename "$dir")"
done
for file in "$THEME_DIR"/color-schemes/*.colors; do
  [ -f "$file" ] || continue
  install_file "$file" "$HOME/.local/share/color-schemes/$(basename "$file")"
done
for dir in "$THEME_DIR"/kvantum/*; do
  [ -d "$dir" ] || continue
  install_dir "$dir" "$HOME/.config/Kvantum/$(basename "$dir")"
done

# --- Icons and cursors -----------------------------------------------------
if [ "$SKIP_ICONS" -eq 0 ]; then
  echo "Icons:"
  if [ -d "$HOME/.local/share/icons/$icon_theme" ]; then
    echo "  present:   $icon_theme"
  else
    clone_source "icons" \
      "$(mget icons.source.repo)" \
      "$(mget icons.source.commit)" \
      "$(mget icons.source.subpath)" \
      "$(mget icons.source.install)"
  fi
fi

if [ "$SKIP_CURSOR" -eq 0 ]; then
  echo "Cursors:"
  if [ -d "$HOME/.local/share/icons/$cursor_theme" ]; then
    echo "  present:   $cursor_theme"
  else
    clone_source "cursors" \
      "$(mget cursor.source.repo)" \
      "$(mget cursor.source.commit)" \
      "$(mget cursor.source.subpath)" \
      "$(mget cursor.source.install)"
  fi
fi

# --- Shared assets ---------------------------------------------------------
if [ -d "$SHARED/gtk-3.0" ]; then
  echo "GTK:"
  for file in "$SHARED/gtk-3.0"/*; do
    [ -f "$file" ] && install_file "$file" "$HOME/.config/gtk-3.0/$(basename "$file")"
  done
  [ -d "$SHARED/gtk-3.0/assets" ] && install_dir "$SHARED/gtk-3.0/assets" "$HOME/.config/gtk-3.0/assets"
fi
if [ -d "$SHARED/gtk-4.0" ]; then
  for file in "$SHARED/gtk-4.0"/*; do
    [ -f "$file" ] && install_file "$file" "$HOME/.config/gtk-4.0/$(basename "$file")"
  done
  [ -d "$SHARED/gtk-4.0/assets" ] && install_dir "$SHARED/gtk-4.0/assets" "$HOME/.config/gtk-4.0/assets"
fi
if [ -f "$SHARED/xsettingsd/xsettingsd.conf" ]; then
  install_file "$SHARED/xsettingsd/xsettingsd.conf" "$HOME/.config/xsettingsd/xsettingsd.conf"
fi

if [ "$INSTALL_PLASMOIDS" -eq 1 ] && [ -d "$SHARED/plasmoids" ]; then
  echo "Plasmoids:"
  for dir in "$SHARED/plasmoids"/*; do
    [ -d "$dir" ] || continue
    install_dir "$dir" "$HOME/.local/share/plasma/plasmoids/$(basename "$dir")"
  done
fi

if [ "$INSTALL_WALLPAPERS" -eq 1 ] && [ -d "$SHARED/wallpapers" ]; then
  echo "Wallpapers:"
  mkdir -p "$HOME/Pictures/Wallpapers"
  for file in "$SHARED/wallpapers"/*; do
    [ -f "$file" ] || continue
    install_file "$file" "$HOME/Pictures/Wallpapers/$(basename "$file")"
  done
fi

# --- Config keys -----------------------------------------------------------
echo "Config:"
for cfg in "$HOME/.config/kdeglobals" "$HOME/.config/kwinrc" \
           "$HOME/.config/ksplashrc" "$HOME/.config/kcminputrc" \
           "$HOME/.config/Kvantum/kvantum.kvconfig"; do
  backup_file "$cfg"
done
apply_key kdeglobals KDE LookAndFeelPackage "$look_and_feel"
apply_key kdeglobals General ColorScheme "$color_scheme"
apply_key kdeglobals Icons Theme "$icon_theme"
apply_key kdeglobals KDE widgetStyle "$widget_style"
apply_key kdeglobals General AccentColor "$(mget appearance.accentColor)"
apply_key kdeglobals General LastUsedCustomAccentColor "$(mget appearance.accentColor)"
apply_key kdeglobals General XftHintStyle "$(mget appearance.xftHintStyle)"
apply_key kdeglobals General XftSubPixel "$(mget appearance.xftSubPixel)"
apply_key kdeglobals KDE contrast "$(mget appearance.contrast)"
apply_key kdeglobals KDE frameContrast "$(mget appearance.frameContrast)"
apply_key kdeglobals General font "$(mget appearance.fonts.font)"
apply_key kdeglobals General fixed "$(mget appearance.fonts.fixed)"
apply_key kdeglobals General menuFont "$(mget appearance.fonts.menuFont)"
apply_key kdeglobals General toolBarFont "$(mget appearance.fonts.toolBarFont)"
apply_key kdeglobals General smallestReadableFont "$(mget appearance.fonts.smallestReadableFont)"
apply_key kdeglobals WM activeFont "$(mget appearance.fonts.windowActiveFont)"
apply_key kdeglobals General TerminalApplication /usr/bin/ghostty
apply_key kdeglobals General TerminalService com.mitchellh.ghostty.desktop

apply_key kwinrc org.kde.kdecoration2 library "$decoration_library"
apply_key kwinrc org.kde.kdecoration2 theme "$decoration_theme"
apply_key kwinrc org.kde.kdecoration2 BorderSize "$decoration_border"
if [ -n "$(mget extras.kwinPlugins)" ] && [ "$(mget extras.kwinPlugins)" != "{}" ]; then
  while IFS=$'\t' read -r key value; do
    apply_key kwinrc Plugins "$key" "$value"
  done < <(python3 - "$MANIFEST" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    plugins = json.load(handle).get("extras", {}).get("kwinPlugins", {})
for key, value in plugins.items():
    print(f"{key}\t{value}")
PY
)
fi

apply_key ksplashrc KSplash Engine KSplashQML
apply_key ksplashrc KSplash Theme "$splash_theme"
apply_key kcminputrc Mouse cursorTheme "$cursor_theme"
apply_key kcminputrc Mouse cursorSize "$cursor_size"
apply_key "$HOME/.config/Kvantum/kvantum.kvconfig" General theme "$kvantum_theme"

# --- Panels ----------------------------------------------------------------
if [ "$PANELS" -eq 1 ]; then
  echo "Panels:"
  if [ -f "$SHARED/panels/plasma-org.kde.plasma.desktop-appletsrc" ]; then
    tmp_panels="$(mktemp -d)"
    sed "s|$source_home|$HOME|g" \
      "$SHARED/panels/plasma-org.kde.plasma.desktop-appletsrc" \
      >"$tmp_panels/plasma-org.kde.plasma.desktop-appletsrc"
    sed "s|$source_home|$HOME|g" \
      "$SHARED/panels/plasmashellrc" >"$tmp_panels/plasmashellrc"
    if [ "$DRY" -eq 0 ]; then
      systemctl --user stop plasma-plasmashell.service || true
    fi
    install_file "$tmp_panels/plasma-org.kde.plasma.desktop-appletsrc" \
      "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    install_file "$tmp_panels/plasmashellrc" "$HOME/.config/plasmashellrc"
    if [ "$DRY" -eq 0 ]; then
      systemctl --user start plasma-plasmashell.service || true
    fi
    rm -r "$tmp_panels"
  fi
fi

# --- SDDM ------------------------------------------------------------------
if [ "$SDDM" -eq 1 ]; then
  echo "SDDM:"
  if [ -n "$sddm_theme" ] && [ -d "$sddm_dir" ]; then
    if [ "$DRY" -eq 1 ]; then
      echo "  + sudo mkdir -p /usr/share/sddm/themes"
      echo "  + sudo cp -a $sddm_dir /usr/share/sddm/themes/$sddm_theme"
      echo "  + write /etc/sddm.conf.d/zz-kde-theme.conf (Current=$sddm_theme)"
    else
      sudo mkdir -p /usr/share/sddm/themes
      if [ -d "/usr/share/sddm/themes/$sddm_theme" ]; then
        mkdir -p "$BACKUP_DIR/sddm"
        sudo mv "/usr/share/sddm/themes/$sddm_theme" "$BACKUP_DIR/sddm/"
      fi
      sudo cp -a "$sddm_dir" "/usr/share/sddm/themes/$sddm_theme"
      sudo mkdir -p /etc/sddm.conf.d
      printf '[Theme]\nCurrent=%s\n' "$sddm_theme" | \
        sudo tee /etc/sddm.conf.d/zz-kde-theme.conf >/dev/null
      echo "  installed: /etc/sddm.conf.d/zz-kde-theme.conf"
    fi
  else
    echo "  no captured SDDM theme — skipping" >&2
  fi
fi

# --- Fonts -----------------------------------------------------------------
echo "Fonts:"
check_font "$(mget fonts.ui)"
check_font "$(mget fonts.fixed)"
check_font "$terminal_font"

# --- Apply live ------------------------------------------------------------
echo "Apply:"
if command -v plasma-apply-desktoptheme >/dev/null 2>&1; then
  run plasma-apply-desktoptheme "$desktop_theme"
fi
if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
  run plasma-apply-colorscheme "$color_scheme"
fi
if command -v plasma-apply-cursortheme >/dev/null 2>&1; then
  run plasma-apply-cursortheme "$cursor_theme"
fi
if command -v kbuildsycoca6 >/dev/null 2>&1; then
  run kbuildsycoca6 --noincremental
fi
if [ "$DRY" -eq 0 ] && command -v dbus-send >/dev/null 2>&1; then
  dbus-send --session --type=signal /KWin org.kde.KWin.reconfigure >/dev/null 2>&1 || true
fi

echo ""
if [ "$DRY" -eq 1 ]; then
  echo "Dry run complete — nothing changed."
else
  echo "Done. Backups (if any): $BACKUP_DIR"
  echo "Log out and back in so KWin, Kvantum, GTK, and SDDM pick everything up."
fi
