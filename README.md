# dotfiles

Personal dotfiles for my development environment on Linux.

## Structure

### Shell Configurations

- **zsh/.zshrc** - Zsh configuration using Oh My Zsh with:
  - Powerlevel10k theme
  - zsh-autosuggestions plugin
  - zsh-syntax-highlighting plugin
  - Custom PATH includes Spicetify and local bin

- **bash/.bashrc** - Bash configuration with:
  - Cargo environment sourced
  - npm-global PATH
  - SDKMAN support for Java SDKs
  - VS Code with Ozone/X11 platform flags
  - Git alias (`g`), open alias

### Terminal

- **alacritty/alacritty.toml** - Alacritty terminal emulator settings with window opacity at 80%

### Editor

- **nvim/** - Neovim configuration based on LazyVim (version 8) with:
  - LSP support for language server functionality
  - Treesitter for syntax highlighting
  - LazyGit integration
  - Snacks dashboard
  - Discord RPC presence
  - Theme configuration
  - Dynamic NVM PATH integration

## Setup

These dotfiles are typically symlinked to their respective locations in `$HOME`:
- `zsh/.zshrc` → `$HOME/.zshrc`
- `bash/.bashrc` → `$HOME/.bashrc`
- `bash/.bash_profile` → `$HOME/.bash_profile`
- `nvim/` → `$HOME/.config/nvim`
- `alacritty/alacritty.toml` → `$HOME/.config/alacritty/alacritty.toml`

## Requirements

- Oh My Zsh (for zsh config)
- Neovim 0.9+ (for LazyVim)
- Alacritty terminal
- SDKMAN, Cargo, npm (optional, for specific features)