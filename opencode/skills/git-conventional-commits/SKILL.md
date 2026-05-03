---
name: git-conventional-commits
description: >
  Enforces Conventional Commits format for all git commit messages and branch naming.
  Use this skill whenever the user asks to commit, write a commit message, name a branch,
  or review git history. Triggers on: "commit this", "write a commit message", "what should
  I name this branch", "git commit", or any task that ends with committing code changes.
---

# Git Conventional Commits Skill

Always format commit messages and branches following these rules.

## Commit Format

```
<type>(<scope>): <short summary>

[optional body]

[optional footer]
```

**Types:**

- `feat` — new feature
- `fix` — bug fix
- `refactor` — code change that neither fixes a bug nor adds a feature
- `chore` — tooling, deps, config changes
- `docs` — documentation only
- `test` — adding or updating tests
- `style` — formatting, whitespace (no logic change)
- `perf` — performance improvement

**Rules:**

- Summary is lowercase, no period at end, max 72 chars
- Scope is the feature folder or module name, e.g. `feat(tasks):`, `fix(auth):`
- Body explains _why_, not _what_

## Examples

```
feat(tasks): add task list container with TanStack Query
fix(auth): handle expired token redirect correctly
refactor(posts): split PostList into container and presentational
chore: update drizzle-orm to v0.31
docs(readme): add feature-driven architecture overview
```

## Branch Naming

```
feat/task-list-feature
fix/auth-token-expiry
chore/update-dependencies
refactor/posts-container-split
```
