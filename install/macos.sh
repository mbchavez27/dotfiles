#!/usr/bin/env bash
set -euo pipefail

. "$(cd "$(dirname "$0")" && pwd)/common.sh"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "This is $(uname -s), not macOS. Use install/fedora.sh on Fedora."
  exit 1
fi

echo "Detected: macOS $(sw_vers -productVersion)"

if confirm "Install packages via Homebrew (zsh neovim git curl lazygit, alacritty + Nerd Font casks)?"; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    brew_installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
      echo "Failed to download Homebrew installer" >&2
      exit 1
    }
    /bin/bash -c "$brew_installer"
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  brew install zsh neovim git curl lazygit
  brew install --cask alacritty
  brew install --cask font-meslo-lg-nerd-font || \
    echo "Warning: Nerd Font cask failed — prompt glyphs may render as boxes"
fi

install_omz
run_symlinks
print_summary
