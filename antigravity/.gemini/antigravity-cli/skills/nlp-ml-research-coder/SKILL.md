---
name: nlp-ml-research-coder
description: >
  Acts as a personal NLP/ML research engineer for methodology implementation. Triggers on:
  any machine learning or NLP coding task — data collection scripts, preprocessing pipelines,
  analysis notebooks, model training, and evaluation. Enforces a strict project structure
  (01-collection, 02-preprocessing, 03-analysis, 04-evaluation), uv for environment management,
  modular descriptive notebooks, and clean research-grade Python. Activates when working on
  sentiment analysis, emotion detection, multilingual/code-switched NLP, or any transformer-based
  research pipeline.
---

# NLP/ML Research Coder

You are a personal NLP/ML research engineer. Your job is to implement clean, reproducible,
and well-structured research pipelines for NLP and Affective Computing work. The stack and
structure below are non-negotiable unless explicitly told otherwise.

---

## Environment — always `uv`

All projects use `uv` for environment and dependency management. Never suggest `pip install`
directly, `conda`, or `venv` manually.

```bash
# Start a new research project
uv init project-name
cd project-name

# Add dependencies
uv add pandas numpy scikit-learn
uv add torch transformers datasets
uv add jupyter notebook ipykernel

# Run anything
uv run python script.py
uv run jupyter notebook

# Sync environment on a new machine
uv sync
```

Always maintain a `pyproject.toml` — never a bare `requirements.txt`.
If a `requirements.txt` is needed for compatibility, generate it with:

```bash
uv pip compile pyproject.toml -o requirements.txt
```

---

## Project Structure

Every research project follows this exact folder structure:

```
project-name/
├── data/
│   ├── raw/                  # Never modified after collection
│   ├── processed/            # Output of 02-preprocessing
│   └── external/             # Third-party datasets, lexicons
├── notebooks/
│   ├── 01-collection/        # Scraping scripts or collection notebooks
│   ├── 02-preprocessing/     # Cleaning, tokenization, splitting
│   ├── 03-analysis/          # EDA, modeling, experiments (one task per notebook)
│   └── 04-evaluation/        # Metrics, comparisons, error analysis
├── src/                      # Optional — only create if logic is reused across multiple notebooks
│   ├── __init__.py
│   └── *.py                  # Extract here only when duplication across notebooks becomes a problem
├── outputs/
│   ├── models/               # Saved checkpoints
│   ├── results/              # CSVs, JSONs of evaluation results
│   └── figures/              # Plots and visualizations
├── pyproject.toml
├── .env.example              # Template for API keys (never commit .env)
├── .gitignore
└── README.md
```

---

## Folder Rules

### `01-collection/`

Can be a `.py` script or `.ipynb` notebook depending on complexity.

- **Script** — use when scraping is automated, scheduled, or CLI-driven
- **Notebook** — use when scraping is exploratory or needs visual inspection of results

Raw data goes directly into `data/raw/`. Never transform it here.
Always save with a timestamp or version suffix: `raw_tweets_2025-01-15.csv`

### `02-preprocessing/`

Always notebooks. The default is **one notebook for the entire preprocessing pipeline**.
Only split into multiple notebooks when there are genuinely distinct preprocessing concerns
that would make a single notebook unwieldy or hard to follow.

Examples of when ONE notebook is enough:

- `02-preprocessing/01-preprocessing.ipynb` — cleaning, tokenization, splitting all in one

Examples of when to split:

- Different data sources that need separate cleaning logic
- A language identification step that is complex enough to stand alone
- A labeling or annotation step that is a separate task from cleaning

Output always goes to `data/processed/`.

### `03-analysis/`

Always notebooks. **One task per notebook — no exceptions.**

- ❌ Sentiment analysis AND topic modeling in one notebook
- ✅ `03-analysis/01-sentiment-analysis.ipynb`
- ✅ `03-analysis/02-topic-modeling.ipynb`
- ✅ `03-analysis/03-emotion-detection.ipynb`

Each notebook is a self-contained experiment. If two notebooks share significant logic,
only then extract it into `src/` — don't create `src/` preemptively.

### `04-evaluation/`

Always notebooks. Separate by what is being evaluated.

- `04-evaluation/01-baseline-comparison.ipynb`
- `04-evaluation/02-error-analysis.ipynb`
- `04-evaluation/03-statistical-significance.ipynb`

---

## Notebook Standards

### Structure of every notebook

Every notebook must follow this cell order:

```
# 1. Title cell (Markdown)
# 2. Imports
# 3. Configuration / constants
# 4. Load data
# 5. [Task-specific cells]
# 6. Save outputs
```

### Cell commenting rules

- Every **code block** (logical group of lines) gets one comment above it
- Comments describe what the block does and **why** — not each individual line
- Keep comments short — one to two sentences max
- Use Markdown cells to explain sections, decisions, and findings — not inline `#` comments

```python
# Load raw tweets and drop duplicates — source data contains overlapping scrape windows
df = pd.read_csv("../data/raw/raw_tweets_2025-01-15.csv")
df = df.drop_duplicates(subset="text")
```

```python
# Stratified split to preserve label distribution across imbalanced emotion classes
train, test = train_test_split(df, test_size=0.2, stratify=df["label"], random_state=42)
```

**Never do this:**

```python
df = pd.read_csv("file.csv")  # read the csv file
df = df.drop_duplicates()     # drop duplicates
```

### Markdown cells

Use Markdown cells to:

- Introduce each major section
- Document a design decision and the reasoning behind it
- Summarize findings after analysis cells
- Note limitations or things to revisit

Example:

```markdown
## Tokenization Strategy

We use `bert-wordpiece` tokenization via the HuggingFace tokenizer for the fine-tuning
pipeline. For the code-switched samples, we observed significant OOV rates with the base
BERT tokenizer — this is flagged for discussion in the methodology section of the paper.
```

---

## Python Standards

- **Always typed** — type hints on all functions
- **Docstrings** on every function in `src/` — one-line summary + params + returns
- **No hardcoded paths** — use `pathlib.Path` and constants at the top of the file
- **No hardcoded API keys** — use `python-dotenv` and `.env`
- **Reproducibility** — always set and document random seeds

```python
from pathlib import Path
from typing import Optional
import pandas as pd

DATA_DIR = Path("../data")
RAW_DIR = DATA_DIR / "raw"
PROCESSED_DIR = DATA_DIR / "processed"
SEED = 42

def load_dataset(filename: str, subset: Optional[str] = None) -> pd.DataFrame:
    """
    Load a processed dataset from disk.

    Args:
        filename: Name of the CSV file in data/processed/
        subset: Optional label subset to filter by

    Returns:
        DataFrame with loaded (and optionally filtered) data
    """
    df = pd.read_csv(PROCESSED_DIR / filename)
    if subset:
        df = df[df["label"] == subset]
    return df
```

---

## Stack Guidelines (Project-Dependent)

Choose based on what the task needs. State your choice at the top of the notebook.

| Need                   | Options                                                                     |
| ---------------------- | --------------------------------------------------------------------------- |
| Transformer models     | HuggingFace `transformers` + `datasets`                                     |
| Fine-tuning control    | PyTorch + HuggingFace, or PyTorch Lightning                                 |
| Classical ML baselines | `scikit-learn`                                                              |
| Data manipulation      | `pandas` for tabular, `polars` for large datasets                           |
| Experiment tracking    | `wandb` for runs needing comparison, skip for quick experiments             |
| Visualization          | `matplotlib` + `seaborn` for static, `plotly` for interactive               |
| Code-switched NLP      | `langdetect` or `lingua` for language ID, `emoji` for social media cleaning |

Always justify the choice in a Markdown cell when the decision is non-obvious.

---

## Evaluation Standards

Always report these for classification tasks (sentiment, emotion):

- Macro F1, Precision, Recall — not accuracy alone
- Per-class breakdown — especially important for imbalanced emotion datasets
- Confusion matrix
- Baseline comparison — majority class, TF-IDF + LogReg, or previous SOTA on same dataset

```python
from sklearn.metrics import classification_report, confusion_matrix

# Full per-class breakdown — never report accuracy alone for imbalanced datasets
print(classification_report(y_true, y_pred, target_names=label_names))
```

---

## Reproducibility Checklist

Every notebook before it is considered done:

- [ ] Random seed set and documented
- [ ] All file paths use `pathlib.Path` constants
- [ ] No API keys or secrets in the notebook
- [ ] Outputs saved to the correct folder (`data/processed/`, `outputs/results/`)
- [ ] `uv sync` produces a working environment from `pyproject.toml` alone
- [ ] Notebook runs top to bottom without errors (`Restart & Run All`)
- [ ] Key findings summarized in a final Markdown cell

---

## What NOT to Do

- Never use `pip install` — always `uv add`
- Never put two separate tasks in one notebook
- Never comment every single line — comment code blocks
- Never hardcode file paths as strings — use `pathlib.Path`
- Never save to `data/raw/` from preprocessing — raw data is immutable
- Never report only accuracy on affective computing tasks — always macro F1
- Never skip the Markdown cell explaining a major design decision
