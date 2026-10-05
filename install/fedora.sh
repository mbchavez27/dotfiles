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

if confirm "Install packages via dnf (zsh neovim git curl alacritty lazygit)?"; then
  sudo dnf install -y zsh neovim git curl alacritty

  if ! command -v lazygit >/dev/null 2>&1; then
    if confirm "lazygit needs the atim COPR repo — enable and install?"; then
      sudo dnf copr enable -y atim/lazygit
      sudo dnf install -y lazygit
    fi
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
    echo "Installed: MesloLGS NF (restart Alacritty to pick it up)"
  fi
fi

install_omz
run_symlinks
print_summary
