#!/usr/bin/env bash
# Snapshot the live KDE/Plasma theme into kde/themes/<slug>/.
#
# Fedora + KDE only. On macOS this script refuses to run so the dotfiles
# checkout used by install/macos.sh can never be overwritten by an empty
# capture.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KDE_DIR="$DOTFILES/kde"

SLUG=""
VENDOR=0
CHECK=0
FORCE=0

usage() {
  cat <<'EOF'
Usage: ./capture-kde.sh [OPTIONS]

Snapshot the live Plasma theme into kde/themes/<slug>/ (theme.json + assets).

OPTIONS
  --slug NAME     Theme slug to write (default: derived from the live
                  desktop theme, e.g. MacSonoma-Dark -> macsonoma-dark)
  --vendor        Copy theme assets (plasma, aurorae, colours, kvantum, sddm)
                  and shared assets (gtk, panels, plasmoids, wallpapers)
  --check         Compare the live session against the tracked theme instead
                  of writing. Exits 1 when they differ.
  --force         Overwrite an existing capture without asking
  -h, --help      Show this help

The script never touches install/common.sh or install/macos.sh.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --slug) SLUG="${2:?--slug needs a value}"; shift 2 ;;
    --vendor) VENDOR=1; shift ;;
    --check) CHECK=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

# --- Platform guards -------------------------------------------------------
if [ "$(uname -s)" != "Linux" ]; then
  echo "KDE capture is Fedora/Linux only. On macOS use install/macos.sh." >&2
  exit 1
fi

if [ ! -f /etc/os-release ]; then
  echo "Cannot detect the distribution (/etc/os-release missing)." >&2
  exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release
if [ "${ID:-}" != "fedora" ]; then
  echo "This is ${ID:-unknown}, not Fedora. Nothing to capture here." >&2
  exit 1
fi

case "${XDG_CURRENT_DESKTOP:-}" in
  *KDE*) ;;
  *) echo "Not a KDE Plasma session (XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-unset})." >&2; exit 1 ;;
esac

for bin in jq kreadconfig6 python3 rsync; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "Missing dependency: $bin (sudo dnf install $bin)" >&2
    exit 1
  fi
done

# --- Read live values ------------------------------------------------------
get() {
  kreadconfig6 --file "$1" --group "$2" --key "$3" --default "" 2>/dev/null || true
}

sddm_current() {
  local file value
  for file in /etc/sddm.conf /etc/sddm.conf.d/*.conf "$HOME/.config/sddm.conf"; do
    [ -f "$file" ] || continue
    value="$(awk -F= '/^[[:space:]]*Current[[:space:]]*=/{gsub(/[[:space:]]/, "", $2); print $2}' "$file" | tail -n1)"
    [ -n "$value" ] && printf '%s\n' "$value"
  done | tail -n1
}

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

look_and_feel="$(get kdeglobals KDE LookAndFeelPackage)"
desktop_theme="$(get plasmarc Theme name)"
color_scheme="$(get kdeglobals General ColorScheme)"
splash_theme="$(get ksplashrc KSplash Theme)"
widget_style="$(get kdeglobals KDE widgetStyle)"
icon_theme="$(get kdeglobals Icons Theme)"
cursor_theme="$(get kcminputrc Mouse cursorTheme)"
cursor_size="$(get kcminputrc Mouse cursorSize)"
decoration_library="$(get kwinrc org.kde.kdecoration2 library)"
decoration_theme="$(get kwinrc org.kde.kdecoration2 theme)"
decoration_border="$(get kwinrc org.kde.kdecoration2 BorderSize)"
kvantum_theme="$(get "$HOME/.config/Kvantum/kvantum.kvconfig" General theme)"
sddm_theme="$(sddm_current)"
font="$(get kdeglobals General font)"
font_fixed="$(get kdeglobals General fixed)"
font_menu="$(get kdeglobals General menuFont)"
font_toolbar="$(get kdeglobals General toolBarFont)"
font_small="$(get kdeglobals General smallestReadableFont)"
font_wm="$(get kdeglobals WM activeFont)"
accent_color="$(get kdeglobals General AccentColor)"
xft_hint="$(get kdeglobals General XftHintStyle)"
xft_subpixel="$(get kdeglobals General XftSubPixel)"
contrast="$(get kdeglobals KDE contrast)"
frame_contrast="$(get kdeglobals KDE frameContrast)"

[ -n "$desktop_theme" ] || { echo "No Plasma desktop theme detected. Is Plasma running?" >&2; exit 1; }
[ -n "$SLUG" ] || SLUG="$(slugify "$desktop_theme")"
[ -n "$cursor_size" ] || cursor_size=24
[ -n "$decoration_border" ] || decoration_border=Normal

aurorae_name="${decoration_theme#__aurorae__svg__}"

extras_json="$(python3 - "$HOME/.config/kwinrc" <<'PY'
import json, os, re, sys

path = sys.argv[1]
extras = {"kwinPlugins": {}, "cornerRadius": None}
if os.path.exists(path):
    section = None
    for raw in open(path, encoding="utf-8"):
        line = raw.strip()
        if line.startswith("[") and line.endswith("]"):
            section = line[1:-1]
            continue
        if section == "Plugins" and "=" in line:
            key, value = line.split("=", 1)
            if re.search(r"blur|round", key, re.IGNORECASE):
                extras["kwinPlugins"][key] = value
print(json.dumps(extras))
PY
)"

theme_dir="$KDE_DIR/themes/$SLUG"
theme_json="$theme_dir/theme.json"

existing_sources='{}'
if [ -f "$theme_json" ]; then
  existing_sources="$(jq -c '.sources // {}' "$theme_json")"
fi

manifest="$(jq -n \
  --arg id "$SLUG" \
  --arg capturedAt "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg sourceHome "$HOME" \
  --arg lookAndFeel "$look_and_feel" \
  --arg desktopTheme "$desktop_theme" \
  --arg colorScheme "$color_scheme" \
  --arg splash "$splash_theme" \
  --arg decorationLibrary "$decoration_library" \
  --arg decorationTheme "$decoration_theme" \
  --arg decorationBorder "$decoration_border" \
  --arg widgetStyle "$widget_style" \
  --arg kvantumTheme "$kvantum_theme" \
  --arg iconTheme "$icon_theme" \
  --arg cursorTheme "$cursor_theme" \
  --arg cursorSize "$cursor_size" \
  --arg sddmTheme "$sddm_theme" \
  --arg font "$font" \
  --arg fontFixed "$font_fixed" \
  --arg fontMenu "$font_menu" \
  --arg fontToolbar "$font_toolbar" \
  --arg fontSmall "$font_small" \
  --arg fontWm "$font_wm" \
  --arg accentColor "$accent_color" \
  --arg xftHint "$xft_hint" \
  --arg xftSubpixel "$xft_subpixel" \
  --arg contrast "$contrast" \
  --arg frameContrast "$frame_contrast" \
  --argjson sources "$existing_sources" \
  --argjson extras "$extras_json" \
  '{
    schemaVersion: 1,
    id: $id,
    label: $desktopTheme,
    capturedAt: $capturedAt,
    sourceHome: $sourceHome,
    plasma: {
      lookAndFeel: $lookAndFeel,
      desktopTheme: $desktopTheme,
      colorScheme: $colorScheme,
      splash: $splash
    },
    decoration: {
      library: $decorationLibrary,
      theme: $decorationTheme,
      borderSize: $decorationBorder
    },
    qt: {
      widgetStyle: $widgetStyle,
      kvantumTheme: $kvantumTheme
    },
    icons: { theme: $iconTheme },
    cursor: { theme: $cursorTheme, size: ($cursorSize | tonumber) },
    sddm: { theme: $sddmTheme, dir: ("sddm/" + $sddmTheme) },
    fonts: {
      ui: ($font | split(",") | .[0]),
      fixed: ($fontFixed | split(",") | .[0]),
      terminal: "MesloLGS NF"
    },
    appearance: {
      accentColor: $accentColor,
      xftHintStyle: $xftHint,
      xftSubPixel: $xftSubpixel,
      contrast: $contrast,
      frameContrast: $frameContrast,
      fonts: {
        font: $font,
        fixed: $fontFixed,
        menuFont: $fontMenu,
        toolBarFont: $fontToolbar,
        smallestReadableFont: $fontSmall,
        windowActiveFont: $fontWm
      }
    },
    extras: $extras,
    sources: $sources
  }')"

# --- Check mode ------------------------------------------------------------
if [ "$CHECK" -eq 1 ]; then
  if [ ! -f "$theme_json" ]; then
    echo "No tracked theme at $theme_json" >&2
    exit 1
  fi
  drift_file="$(mktemp)"
  if diff -u \
      <(jq -S 'del(.capturedAt)' "$theme_json") \
      <(printf '%s\n' "$manifest" | jq -S 'del(.capturedAt)') >"$drift_file"; then
    echo "Theme matches $theme_json"
    exit 0
  fi
  echo "Live session differs from $theme_json:" >&2
  cat "$drift_file" >&2
  exit 1
fi

# --- Write mode ------------------------------------------------------------
if [ -f "$theme_json" ] && [ "$FORCE" -ne 1 ]; then
  if ! diff -q <(jq -S 'del(.capturedAt)' "$theme_json") \
               <(printf '%s\n' "$manifest" | jq -S 'del(.capturedAt)') >/dev/null; then
    printf 'Theme metadata changed. Overwrite %s? [y/N] ' "$theme_json"
    reply=""
    read -r reply || true
    case "$reply" in
      [Yy]*) ;;
      *) echo "Aborted."; exit 1 ;;
    esac
  fi
fi

mkdir -p "$theme_dir"
printf '%s\n' "$manifest" >"$theme_json"
echo "Wrote $theme_json"

if [ "$VENDOR" -eq 1 ]; then
  need_dir() {
    if [ ! -d "$1" ]; then
      echo "Warning: missing theme asset dir: $1" >&2
      return 1
    fi
  }

  copy_dir() {
    local src="$1" dest="$2"
    need_dir "$src" || return 0
    mkdir -p "$dest"
    rsync -a --delete "$src/" "$dest/"
    echo "  vendored: $dest"
  }

  copy_file() {
    local src="$1" dest="$2"
    if [ ! -f "$src" ]; then
      echo "Warning: missing theme asset: $src" >&2
      return 0
    fi
    mkdir -p "$(dirname "$dest")"
    cp -a "$src" "$dest"
    echo "  vendored: $dest"
  }

  echo "Vendoring assets into $theme_dir"

  copy_dir "$HOME/.local/share/plasma/look-and-feel/$look_and_feel" \
           "$theme_dir/plasma/look-and-feel/$look_and_feel"
  copy_dir "$HOME/.local/share/plasma/desktoptheme/$desktop_theme" \
           "$theme_dir/plasma/desktoptheme/$desktop_theme"
  copy_dir "$HOME/.local/share/aurorae/themes/$aurorae_name" \
           "$theme_dir/aurorae/$aurorae_name"
  for scale in 1.25x 1.5x; do
    copy_dir "$HOME/.local/share/aurorae/themes/$aurorae_name-$scale" \
             "$theme_dir/aurorae/$aurorae_name-$scale"
  done
  copy_file "$HOME/.local/share/color-schemes/$color_scheme.colors" \
            "$theme_dir/color-schemes/$color_scheme.colors"

  # Kvantum themes live in a directory named after the pack (MacSonoma) while
  # the applied theme name is a .kvconfig inside it (MacSonomaDark).
  kvantum_dir="$HOME/.config/Kvantum/$kvantum_theme"
  if [ ! -d "$kvantum_dir" ]; then
    for candidate in "$HOME/.config/Kvantum"/*/"$kvantum_theme.kvconfig"; do
      [ -f "$candidate" ] || continue
      kvantum_dir="$(dirname "$candidate")"
      break
    done
  fi
  copy_dir "$kvantum_dir" "$theme_dir/kvantum/$(basename "$kvantum_dir")"
  if [ -n "$sddm_theme" ]; then
    copy_dir "/usr/share/sddm/themes/$sddm_theme" \
             "$theme_dir/sddm/$sddm_theme"
  fi

  copy_dir "$HOME/.config/gtk-3.0" "$KDE_DIR/shared/gtk-3.0"
  copy_dir "$HOME/.config/gtk-4.0" "$KDE_DIR/shared/gtk-4.0"
  copy_file "$HOME/.config/xsettingsd/xsettingsd.conf" \
            "$KDE_DIR/shared/xsettingsd/xsettingsd.conf"
  copy_dir "$HOME/.local/share/plasma/plasmoids" "$KDE_DIR/shared/plasmoids"
  if [ -d "$HOME/Pictures/Wallpapers" ]; then
    copy_dir "$HOME/Pictures/Wallpapers" "$KDE_DIR/shared/wallpapers"
  fi

  # Panel layout: keep only panels that still exist in appletsrc, drop the
  # machine-specific [Updates] bookkeeping from plasmashellrc.
  mkdir -p "$KDE_DIR/shared/panels"
  cp -a "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" \
        "$KDE_DIR/shared/panels/plasma-org.kde.plasma.desktop-appletsrc"
  python3 - "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" \
            "$HOME/.config/plasmashellrc" \
            "$KDE_DIR/shared/panels/plasmashellrc" <<'PY'
import re
import sys

applets_path, shell_path, out_path = sys.argv[1], sys.argv[2], sys.argv[3]


def sections(text):
    header = None
    body = []
    for line in text.splitlines():
        if line.startswith("[") and line.endswith("]"):
            if header is not None:
                yield header, body
            header = line
            body = []
        else:
            body.append(line)
    if header is not None:
        yield header, body


active = set()
for header, body in sections(open(applets_path, encoding="utf-8").read()):
    match = re.fullmatch(r"\[Containments\]\[(\d+)\]", header)
    if match and any(line.strip() == "plugin=org.kde.panel" for line in body):
        active.add(match.group(1))

kept = []
for header, body in sections(open(shell_path, encoding="utf-8").read()):
    panel = re.fullmatch(r"\[PlasmaViews\]\[Panel (\d+)\](?:\[Defaults\])?", header)
    if panel and panel.group(1) not in active:
        continue
    if header == "[Updates]":
        continue
    kept.append(header)
    kept.extend(body)

with open(out_path, "w", encoding="utf-8") as handle:
    handle.write("\n".join(kept).rstrip() + "\n")
PY
  echo "  vendored: $KDE_DIR/shared/panels"

  echo "Vendored size:"
  du -sh "$theme_dir" "$KDE_DIR/shared"
fi

echo ""
echo "Next:"
echo "  ./install/kde.sh --theme $SLUG --dry-run"
