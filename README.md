# dotfiles

Personal dotfiles for my development environment on Fedora and macOS.

## OpenCode Configuration

AI assistant configured via `~/.config/opencode/AGENTS.md`.

**Agent Identity:**
- Software engineer (frontend: Next.js, TypeScript) + AI researcher (NLP, Affective Computing)
- Undergraduate level — flag when scope exceeds this

**Coding Standards:**
- Strict TypeScript with explicit typing, no `any`
- Functional components, native `fetch` only, zero commented-out code
- Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`)

**Available Skills:**
- `lead-frontend-engineer` — Next.js architecture enforcement
- `git-conventional-commits` — commit message and branch naming
- `research-writing-coach` — academic writing guidance
- `nlp-ml-research-coder` — ML/NLP implementation pipelines

## Structure

### Shell Configurations

- **zsh/.zshrc** - Zsh configuration using Oh My Zsh with:
  - Powerlevel10k theme
  - zsh-autosuggestions plugin
  - zsh-syntax-highlighting plugin
  - Custom PATH includes Spicetify, local bin, and opencode

- **zsh/.p10k.zsh** - Powerlevel10k prompt configuration (MesloLGS NF Nerd Font)

- **bash/.bashrc** - Bash configuration with:
  - Cargo environment sourced (guarded — skipped if not installed)
  - npm-global PATH
  - SDKMAN support for Java SDKs
  - VS Code with Ozone/X11 flags (Linux only)
  - Git alias (`g`), open alias (Linux only)

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

### AI Assistant

- **opencode/** - Global OpenCode configuration symlinked to `~/.config/opencode`:
  - `AGENTS.md` - agent identity and coding standards
  - `opencode.json` - permissions and instructions
  - `skills/` - six custom skills (frontend, git, research, NLP, scrum, sprint)

### Installer

- **install/common.sh** - shared logic: symlinks, backups, Oh My Zsh setup
- **install/fedora.sh** - Fedora entry point (dnf)
- **install/macos.sh** - macOS entry point (Homebrew)

## Installation

### Step 1: Set up the dotfile repo (both OSes)

```bash
git clone git@github.com:mbchavez27/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Do not move the folder after installing — the symlinks point into this clone.

### Step 2: Run the installer

#### Fedora

```bash
./install/fedora.sh
```

Prompts before installing:

- `sudo dnf install zsh neovim git curl alacritty`
- `lazygit` via the atim COPR repo (needed for the nvim LazyGit keymap)
- MesloLGS NF Nerd Font → `~/.local/share/fonts` (no RPM exists for it)

Then installs Oh My Zsh + powerlevel10k + zsh-autosuggestions + zsh-syntax-highlighting,
and symlinks all configs. Existing files are moved to `~/.dotfiles-backup/<timestamp>/`
— nothing is deleted. Skip prompts with `YES=1 ./install/fedora.sh`.

#### macOS

```bash
./install/macos.sh
```

Prompts before installing:

- Homebrew (installed first if missing)
- `brew install zsh neovim git curl lazygit`
- `brew install --cask alacritty font-meslo-lg-nerd-font`

Then the same Oh My Zsh setup, symlinks, and backups as Fedora.
The script exits with a hint if run on the wrong OS — no flags needed.

### Step 3: After running the commands

#### Both OSes

1. **Restart the shell** — open a new terminal tab or run `exec zsh`
   (already-open shells keep the old config)
2. **Install the opencode CLI** (the config is already symlinked, the binary is not):
   ```bash
   curl -fsSL https://opencode.ai/install | bash
   # or: npm install -g opencode-ai
   # or (macOS): brew install anomalyco/tap/opencode
   ```
3. **Git identity** (fresh machine):
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```
4. **Toolchains** — the PATH lines in `.bashrc` stay inert until these exist:
   - Rust/Cargo: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
   - Java (SDKMAN): `curl -s "https://get.sdkman.io" | bash`
   - Node: install nvm, then `nvm install --lts`
5. **First `nvim` launch** — LazyVim downloads plugins automatically (~1–2 min,
   needs network). Run `:Mason` later to install LSP servers per language
6. Prompt shows boxes/tofu? The terminal font is not the Nerd Font — see per-OS steps below

#### Fedora

```bash
fc-cache -fv    # refresh font cache if the script downloaded the font, then restart Alacritty
```

Nothing else required — an existing Fedora setup keeps working as-is, and the
Linux-only aliases (VS Code Ozone/X11, `xdg-open`) stay active.

Optional: VS Code via `sudo dnf install code` (Microsoft repo) or
`flatpak install com.visualstudio-code`.

#### macOS

- **Font:** if p10k glyphs are broken, add the family reported by `p10k diagnose`
  to `~/.config/alacritty/alacritty.toml`:
  ```toml
  [font]
  normal = { family = "MesloLGS Nerd Font" }
  ```
  (family names differ slightly from Fedora's — that's why it is not hardcoded)
- **VS Code (optional):** `brew install --cask visual-studio-code`, then
  `Cmd+Shift+P` → "Shell Command: Install 'code' in PATH"
  (the Ozone/X11 alias is Linux-only and stays off here)
- **Docker (optional):** Docker Desktop (`brew install --cask docker`) if you
  want the `mysql-docker` alias

## Manual Symlink Table (fallback)

If you prefer not to use the installer:

```bash
ln -s ~/dotfiles/zsh/.zshrc              ~/.zshrc
ln -s ~/dotfiles/zsh/.p10k.zsh           ~/.p10k.zsh
ln -s ~/dotfiles/bash/.bashrc            ~/.bashrc
ln -s ~/dotfiles/bash/.bash_profile      ~/.bash_profile
ln -s ~/dotfiles/nvim                    ~/.config/nvim
ln -s ~/dotfiles/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
ln -s ~/dotfiles/opencode                ~/.config/opencode
```

You still need: Oh My Zsh + powerlevel10k + the two zsh plugins, Neovim 0.9+,
Alacritty, and a Nerd Font.

## Requirements

Installed by the scripts:

- Oh My Zsh, powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting
- Neovim 0.9+, Alacritty, lazygit, MesloLGS NF Nerd Font

Not installed (see Step 3): opencode CLI, Rust, SDKMAN, nvm/Node, VS Code, Docker
