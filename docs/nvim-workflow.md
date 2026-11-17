# Daily workflow in nvim (no VS Code)

`<space>` is the leader key. Press it and wait: which-key lists every
shortcut available in the current buffer, so you never have to memorize this page.

## Everyday editing

| Task | Keys |
|---|---|
| Find file / grep the project | `<space><space>` / `<space>/` |
| Recent files / open buffers | `<space>fr` / `<space>,` |
| File explorer (right side) | `<space>e` |
| Switch buffers ("tabs") | `Shift+h` / `Shift+l` (`Ctrl+Tab` may be taken by Ghostty) |
| Split navigation | `Ctrl+h/j/k/l` |
| Terminal | `Ctrl+/` (toggle) |
| Search & replace across files | `<space>sr` |
| Save / format | `Ctrl+s` / `<space>cf` (format also runs on save) |

## Software engineering (Next.js, TypeScript, Svelte, Go, Java, C/C++)

```bash
cd ~/projects/app && nvim
```

| Task | Keys |
|---|---|
| Definition / references / hover docs | `gd` / `gr` / `K` |
| Rename symbol / code action (quick fix, imports) | `<space>cr` / `<space>ca` |
| Project diagnostics / buffer diagnostics | `<space>xx` / `<space>xX` |
| Next / previous error | `]d` / `[d` |
| Run tests: file / nearest / summary | `<space>tt` / `<space>tr` / `<space>ts` |
| Debugger: breakpoint / start-continue / UI | `<space>db` / `<space>dc` / `<space>du` |
| Git: lazygit / blame line / next hunk | `<space>gg` / `<space>gb` / `]h` |

Run `npm run dev` or `go run .` in a second Ghostty tab, or in `Ctrl+/`.

## AI agents (sidekick)

| Task | Keys |
|---|---|
| Claude Code / opencode / pick any CLI (incl. agy) | `<space>ac` / `<space>ao` / `<space>as` |
| Toggle the AI split / jump into it | `<space>aa` / `Ctrl+.` |
| Send selection / current thing / whole file | `<space>av` (visual) / `<space>at` / `<space>af` |
| Send the current diagnostics | `<space>aD` |
| Prompt library (explain, fix, tests...) | `<space>ap` |

Your skills (`lead-software-engineer`, `nlp-ml-research-coder`, ...) apply
automatically, because the split runs the same Claude Code CLI.

## AI research (Python / NLP)

### New project

```bash
uv init thesis-sentiment && cd thesis-sentiment
uv add transformers datasets pandas scikit-learn
uv add --dev ipykernel pytest
uv run python -m ipykernel install --user --name thesis-sentiment   # once per project
nvim
```

In nvim, `<space>cv` selects `.venv`, so pyright, ruff and the debugger all
use the project's packages.

### Notebook-style work (Molten)

Write normal `.py` files split into `# %%` cells. `.ipynb` files open the
same way (jupytext converts them) and are saved back as notebooks.

| Task | Keys |
|---|---|
| Start a kernel (pick `thesis-sentiment`) | `<space>mi` |
| Run selected lines | select, then `<space>mv` |
| Re-run the current cell | `<space>mr` |
| Show / hide output | `<space>mo` / `<space>mh` |

Plots and images render inline in Ghostty (via ImageMagick).

### Data, debugging, tests

- **CSV/TSV datasets:** `:CsvViewToggle` aligns the columns.
- **Debug a training script:** `<space>db` on a line, then `<space>dc` (debugpy).
- **Tests:** pytest through `<space>tt` / `<space>tr`.
- **Long training runs:** run them in their own Ghostty tab
  (`uv run python train.py`), not inside nvim.

## Writing

- **Papers:** Overleaf in the browser.
- **Notes / READMEs:** Markdown renders inline; `<space>cp` opens a live browser preview.

## Things VS Code did that you now handle differently

| Need | Do this |
|---|---|
| Heavy `.ipynb` (widgets, rich tables) | `uvx --from jupyterlab jupyter-lab`: no permanent install, ~100 MB in uv's cache (est.), freed with `uv cache clean` |
| Remote GPU server / lab machine | `ssh` in and run nvim there; on Fedora: clone the dotfiles + `./install/fedora.sh` |
| Live Share pair programming | no nvim equivalent; share a terminal (e.g. `tmate`) or screen share |
| Extension marketplace | `:LazyExtras` (languages, tools); `:Mason` (language servers) |
| Settings UI | edit `~/dotfiles/nvim/lua/...` directly; `<space>fc` finds config files |
