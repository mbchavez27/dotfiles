#!/usr/bin/env bash
# Removes what install/macos.sh, install/fedora.sh and install/kde.sh put on disk.
# Every group asks first. Nothing inside ~/dotfiles is touched.
#
#   ./install/uninstall.sh              interactive, one prompt per group/package
#   DRY_RUN=1 ./install/uninstall.sh    print what would be removed, change nothing
#   YES=1 ./install/uninstall.sh        answer yes to everything (careful)
#
# Full list of locations: docs/storage.md
set -uo pipefail

. "$(cd "$(dirname "$0")" && pwd)/common.sh"

DRY_RUN="${DRY_RUN:-}"
OS="$(uname -s)"

run() {
  if [ -n "$DRY_RUN" ]; then
    echo "  [dry-run] $*"
  else
    "$@"
  fi
}

size_of() {
  du -sh "$1" 2>/dev/null | cut -f1
}

# Remove each existing path after one confirmation for the whole group.
remove_paths() {
  local label="$1"
  shift
  local found=() p
  for p in "$@"; do
    if [ -e "$p" ] || [ -L "$p" ]; then
      found+=("$p")
    fi
  done
  if [ ${#found[@]} -eq 0 ]; then
    echo "  $label: nothing to remove"
    return 0
  fi
  echo "  $label:"
  for p in "${found[@]}"; do
    echo "    $p ($(size_of "$p"))"
  done
  if confirm "  Delete these?"; then
    for p in "${found[@]}"; do
      run rm -rf "$p"
    done
    echo "  ${DRY_RUN:+would be }removed: $label"
  else
    echo "  skipped: $label"
  fi
}

section() {
  echo ""
  echo "== $1"
}

# --- Neovim ----------------------------------------------------------------
section "Neovim data (plugins, Mason LSP servers, nvim Python host, state, cache)"
echo "  Config stays in ~/dotfiles/nvim; only downloaded data is removed."
remove_paths "neovim data" \
  "$HOME/.local/share/nvim" \
  "$HOME/.local/state/nvim" \
  "$HOME/.cache/nvim"

section "Jupyter kernels you registered for Molten"
if [ "$OS" = "Darwin" ]; then
  kernel_root="$HOME/Library/Jupyter/kernels"
else
  kernel_root="$HOME/.local/share/jupyter/kernels"
fi
if [ -d "$kernel_root" ]; then
  for k in "$kernel_root"/*; do
    [ -d "$k" ] || continue
    remove_paths "kernel $(basename "$k")" "$k"
  done
else
  echo "  none registered"
fi

# --- Symlinks --------------------------------------------------------------
section "Config symlinks (only links that point into $DOTFILES)"
links=(
  "$HOME/.zshrc" "$HOME/.p10k.zsh" "$HOME/.bashrc" "$HOME/.bash_profile"
  "$HOME/.config/nvim" "$HOME/.config/ghostty/config" "$HOME/.config/opencode"
  "$HOME/.claude/skills" "$HOME/.claude/settings.json"
  "$HOME/.gemini/antigravity-cli/skills"
)
ours=()
for l in "${links[@]}"; do
  if [ -L "$l" ] && [[ "$(readlink "$l")" == "$DOTFILES"* ]]; then
    ours+=("$l")
    echo "    $l -> $(readlink "$l")"
  fi
done
if [ ${#ours[@]} -eq 0 ]; then
  echo "  no dotfiles symlinks found"
elif confirm "  Remove these symlinks? (your shell will have no .zshrc until you restore one)"; then
  for l in "${ours[@]}"; do
    run rm "$l"
  done
  echo "  ${DRY_RUN:+would have }removed symlinks. Originals, if any, are in ~/.dotfiles-backup/<timestamp>/"
fi

# --- Shell framework -------------------------------------------------------
section "Oh My Zsh (includes powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting)"
remove_paths "oh-my-zsh" "$HOME/.oh-my-zsh"
p10k_caches=()
for f in "$HOME"/.cache/p10k-* "$HOME"/.cache/gitstatus; do
  [ -e "$f" ] && p10k_caches+=("$f")
done
if [ ${#p10k_caches[@]} -gt 0 ]; then
  remove_paths "powerlevel10k cache" "${p10k_caches[@]}"
fi

# --- Packages --------------------------------------------------------------
# zsh, git and curl are deliberately kept: the OS and other tools rely on them.
remove_pkg() {
  local manager="$1" pkg="$2"
  case "$manager" in
    brew)
      brew list --formula "$pkg" >/dev/null 2>&1 || return 0
      confirm "  brew uninstall $pkg?" && run brew uninstall "$pkg"
      ;;
    cask)
      brew list --cask "$pkg" >/dev/null 2>&1 || return 0
      confirm "  brew uninstall --cask $pkg?" && run brew uninstall --cask "$pkg"
      ;;
    dnf)
      rpm -q "$pkg" >/dev/null 2>&1 || return 0
      confirm "  sudo dnf remove $pkg?" && run sudo dnf remove -y "$pkg"
      ;;
  esac
}

if [ "$OS" = "Darwin" ]; then
  section "Homebrew packages (zsh, git, curl and Homebrew itself are kept)"
  if command -v brew >/dev/null 2>&1; then
    for pkg in imagemagick fd ripgrep lazygit neovim; do
      remove_pkg brew "$pkg"
    done
    for pkg in ghostty font-meslo-for-powerlevel10k; do
      remove_pkg cask "$pkg"
    done
    if confirm "  brew autoremove + cleanup (drops orphaned deps such as ImageMagick's libraries)?"; then
      run brew autoremove
      run brew cleanup --prune=all
    fi
  else
    echo "  Homebrew not found"
  fi
  remove_paths "Ghostty app data" "$HOME/Library/Application Support/com.mitchellh.ghostty"
else
  section "dnf packages (zsh, git and curl are kept)"
  for pkg in ImageMagick fd-find ripgrep uv lazygit ghostty neovim; do
    remove_pkg dnf "$pkg"
  done
  for copr in atim/lazygit scottames/ghostty; do
    if dnf copr list 2>/dev/null | grep -q "$copr"; then
      confirm "  sudo dnf copr remove $copr?" && run sudo dnf copr remove -y "$copr"
    fi
  done
  remove_paths "MesloLGS NF font" "$HOME/.local/share/fonts/meslolgs-nf"
  [ -z "$DRY_RUN" ] && command -v fc-cache >/dev/null 2>&1 && fc-cache -f >/dev/null 2>&1
fi

# --- KDE (Fedora) ----------------------------------------------------------
if [ "$OS" = "Linux" ] && [ -d "$DOTFILES/kde/themes" ]; then
  section "KDE Plasma theme (from install/kde.sh)"
  echo "  Switch to Breeze in System Settings first. kdeglobals/kwinrc edits are not reverted."
  kde_paths=()
  for theme in "$DOTFILES"/kde/themes/*; do
    [ -d "$theme" ] || continue
    for d in "$theme"/plasma/look-and-feel/*; do kde_paths+=("$HOME/.local/share/plasma/look-and-feel/$(basename "$d")"); done
    for d in "$theme"/plasma/desktoptheme/*; do kde_paths+=("$HOME/.local/share/plasma/desktoptheme/$(basename "$d")"); done
    for d in "$theme"/aurorae/*; do kde_paths+=("$HOME/.local/share/aurorae/themes/$(basename "$d")"); done
    for f in "$theme"/color-schemes/*.colors; do kde_paths+=("$HOME/.local/share/color-schemes/$(basename "$f")"); done
    for d in "$theme"/kvantum/*; do kde_paths+=("$HOME/.config/Kvantum/$(basename "$d")"); done
  done
  for d in "$DOTFILES"/kde/shared/plasmoids/*; do kde_paths+=("$HOME/.local/share/plasma/plasmoids/$(basename "$d")"); done
  for f in "$DOTFILES"/kde/shared/wallpapers/*; do kde_paths+=("$HOME/Pictures/Wallpapers/$(basename "$f")"); done
  remove_paths "theme assets, plasmoids, wallpapers" "${kde_paths[@]}"
  remove_paths "WhiteSur icons and cursors" \
    "$HOME/.local/share/icons/WhiteSur" \
    "$HOME/.local/share/icons/WhiteSur-dark" \
    "$HOME/.local/share/icons/WhiteSur-light" \
    "$HOME/.local/share/icons/WhiteSur-cursors"
  remove_paths "GTK theme sync + xsettingsd" \
    "$HOME/.config/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/colors.css" \
    "$HOME/.config/gtk-3.0/window_decorations.css" "$HOME/.config/gtk-3.0/assets" \
    "$HOME/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/colors.css" \
    "$HOME/.config/gtk-4.0/window_decorations.css" "$HOME/.config/gtk-4.0/assets" \
    "$HOME/.config/xsettingsd/xsettingsd.conf"
  if [ -f /etc/sddm.conf.d/zz-kde-theme.conf ]; then
    echo "  SDDM login theme: /usr/share/sddm/themes/WhiteSur-dark, /etc/sddm.conf.d/zz-kde-theme.conf"
    if confirm "  Remove SDDM theme (sudo)?"; then
      run sudo rm -rf /usr/share/sddm/themes/WhiteSur-dark /etc/sddm.conf.d/zz-kde-theme.conf
    fi
  fi
  for pkg in kvantum qt6-qtmultimedia; do
    remove_pkg dnf "$pkg"
  done
fi

# --- Backups ---------------------------------------------------------------
section "Installer backups (your original configs from before the dotfiles)"
remove_paths "~/.dotfiles-backup (only delete if you never want the originals back)" \
  "$HOME/.dotfiles-backup"

echo ""
echo "Done.${DRY_RUN:+ (dry run, nothing changed)} The repo itself is untouched: rm -rf $DOTFILES to remove it."
