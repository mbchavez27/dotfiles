#!/usr/bin/env bash
# Shared logic for install/fedora.sh and install/macos.sh.
# Sourced, not executed: bash install/common.sh → exits after definitions.

if [ -n "${BASH_SOURCE:-}" ] && [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo "Source this file, don't execute it: ./install/fedora.sh or ./install/macos.sh"
  exit 1
fi

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d%H%M%S)"

confirm() {
  if [ -n "${YES:-}" ]; then
    return 0
  fi
  printf '%s [y/N] ' "$1"
  reply=""
  read -r reply || true
  [[ "$reply" =~ ^[Yy] ]]
}

backup_dest() {
  local dest="$1"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/"
    echo "  backed up: $dest -> $BACKUP_DIR/"
  fi
}

symlink() {
  local src="$1" dest="$2"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "  linked:    $dest"
    return 0
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if ! confirm "Replace $dest? (original moved to backup)"; then
      echo "  skipped:   $dest"
      return 0
    fi
    backup_dest "$dest"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "  linked:    $dest -> $src"
}

install_omz() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    omz_installer="$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
      echo "Failed to download Oh My Zsh installer" >&2
      return 1
    }
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$omz_installer"
  else
    echo "Oh My Zsh: already installed"
  fi

  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  if [ ! -d "$custom/themes/powerlevel10k" ]; then
    git clone -q https://github.com/romkatv/powerlevel10k "$custom/themes/powerlevel10k"
    echo "Installed: powerlevel10k"
  fi
  local plugin
  for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    if [ ! -d "$custom/plugins/$plugin" ]; then
      git clone -q "https://github.com/zsh-users/$plugin" "$custom/plugins/$plugin"
      echo "Installed: $plugin"
    fi
  done
}

# Dedicated Python host for nvim remote plugins (Molten). ~10 MB, isolated from project venvs.
setup_nvim_python() {
  local venv="$HOME/.local/share/nvim/python"
  if [ -x "$venv/bin/python" ] && "$venv/bin/python" -c "import pynvim, jupyter_client" 2>/dev/null; then
    echo "nvim python host: already set up"
    return 0
  fi
  if ! command -v uv >/dev/null 2>&1; then
    echo "uv not found — skipping nvim python host (install uv, then re-run)"
    return 0
  fi
  if confirm "Create nvim Python host at $venv (pynvim, jupyter_client, nbformat — ~10 MB)?"; then
    uv venv -q "$venv"
    uv pip install -q --python "$venv/bin/python" pynvim jupyter_client nbformat
    echo "Installed: nvim python host"
  fi
}

# VisiData (vd): terminal spreadsheet for CSV/TSV/JSON datasets.
# Installed as a uv tool so it reuses uv's Python (brew would pull another Python, ~70 MB).
setup_visidata() {
  if command -v vd >/dev/null 2>&1; then
    echo "visidata: already installed"
    return 0
  fi
  if ! command -v uv >/dev/null 2>&1; then
    echo "uv not found — skipping visidata (install uv, then re-run)"
    return 0
  fi
  if confirm "Install VisiData CSV viewer via uv tool (~40 MB)?"; then
    uv tool install -q visidata
    echo "Installed: visidata (vd)"
  fi
}

run_symlinks() {
  echo "Symlinking configs (existing files backed up):"
  symlink "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
  symlink "$DOTFILES/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
  symlink "$DOTFILES/bash/.bashrc" "$HOME/.bashrc"
  symlink "$DOTFILES/bash/.bash_profile" "$HOME/.bash_profile"
  symlink "$DOTFILES/nvim" "$HOME/.config/nvim"
  symlink "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"
  symlink "$DOTFILES/visidata/.visidatarc" "$HOME/.visidatarc"
  symlink "$DOTFILES/opencode" "$HOME/.config/opencode"
  symlink "$DOTFILES/claude/.claude/skills" "$HOME/.claude/skills"
  symlink "$DOTFILES/claude/.claude/settings.json" "$HOME/.claude/settings.json"
  symlink "$DOTFILES/antigravity/.gemini/antigravity-cli/skills" "$HOME/.gemini/antigravity-cli/skills"
}

print_summary() {
  echo ""
  echo "Done. Backups (if any): $BACKUP_DIR"
  echo ""
  echo "Next steps:"
  echo "  1. Restart the shell (new tab or: exec zsh)"
  echo "  2. Run 'p10k diagnose' — if glyphs are boxes, MesloLGS NF is missing"
  echo "  3. Run 'nvim' once — LazyVim downloads plugins on first launch, then :checkhealth"
  echo "  4. Launch Ghostty — config comes from ghostty/config"
  echo "  5. See README.md 'After Install' for what still needs manual setup"
}
