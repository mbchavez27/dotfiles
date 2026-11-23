#!/usr/bin/env bash
set -euo pipefail

. "$(cd "$(dirname "$0")" && pwd)/common.sh"

if [ ! -f /etc/os-release ]; then
  echo "Cannot detect OS (no /etc/os-release). Use install/macos.sh on macOS."
  exit 1
fi
. /etc/os-release
if [ "${ID:-}" != "fedora" ]; then
  echo "This is ${ID:-unknown}, not Fedora. Use install/macos.sh on macOS."
  exit 1
fi

echo "Detected: Fedora (${VERSION_ID:-?})"

if confirm "Install packages via dnf (zsh neovim git curl)?"; then
  sudo dnf install -y zsh neovim git curl

  if ! command -v lazygit >/dev/null 2>&1; then
    if confirm "lazygit needs the atim COPR repo — enable and install?"; then
      sudo dnf copr enable -y atim/lazygit
      sudo dnf install -y lazygit
    fi
  fi

  nvim_deps=()
  command -v rg >/dev/null 2>&1 || nvim_deps+=(ripgrep)
  command -v fd >/dev/null 2>&1 || nvim_deps+=(fd-find)
  command -v uv >/dev/null 2>&1 || nvim_deps+=(uv)
  if [ ${#nvim_deps[@]} -gt 0 ]; then
    sudo dnf install -y "${nvim_deps[@]}"
  fi
  if ! command -v magick >/dev/null 2>&1 && \
     confirm "Install ImageMagick for inline plots in nvim (~60 MB with deps)?"; then
    sudo dnf install -y ImageMagick
  fi
fi

if ! command -v ghostty >/dev/null 2>&1; then
  if confirm "Ghostty not found — install via the scottames COPR?"; then
    sudo dnf copr enable -y scottames/ghostty
    sudo dnf install -y ghostty
  fi
fi

if command -v fc-list >/dev/null 2>&1 && ! fc-list | grep -qi "MesloLGS NF"; then
  if confirm "Nerd Font (MesloLGS NF) missing — download to ~/.local/share/fonts?"; then
    font_dir="$HOME/.local/share/fonts/meslolgs-nf"
    mkdir -p "$font_dir"
    base="https://github.com/romkatv/powerlevel10k-media/raw/master"
    for style in Regular Bold Italic "Bold Italic"; do
      curl -fsSL "$base/MesloLGS%20NF%20${style// /%20}.ttf" \
        -o "$font_dir/MesloLGS NF ${style}.ttf"
    done
    fc-cache -f
    echo "Installed: MesloLGS NF (restart Ghostty to pick it up)"
  fi
fi

install_omz
run_symlinks
setup_nvim_python
setup_visidata
setup_euporie

if [[ "${XDG_CURRENT_DESKTOP:-}" == *KDE* ]]; then
  if confirm "Apply the captured KDE Plasma theme (MacSonoma, WhiteSur, Kvantum)?"; then
    bash "$DOTFILES/install/kde.sh"
  fi
else
  echo "KDE not detected — skipping Plasma theme setup"
fi

print_summary
