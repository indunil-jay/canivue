---
name: git-commit
description: "Craft clear, atomic, and conventional git commit messages based on staged changes and repository standards."
---

# Git Commit Skill

Use this skill whenever crafting, reviewing, or executing git commits to ensure clean git history and adherence to the repository's commit standards.

---

## 1. Core Principles

- **Atomic Commits**: Each commit represents a single logical change. Do not mix unrelated refactors, feature additions, and dependency updates into one monolithic commit.
- **Imperative Present Tense**: Write subjects in the imperative mood (e.g., `add`, `fix`, `refactor`, NOT `added`, `fixes`, or `adding`).
- **Explain "Why", Not Just "What"**: The code diff shows *what* changed; the commit message body must explain *why* it changed and any non-obvious consequences.
- **Safety First**: Never commit secrets, credentials, environment files (`.env`), or build artifacts. Verify `git status` before committing.

---

## 2. Commit Message Structure

Follow the **Conventional Commits** specification:

```text
<type>(<scope>): <short summary in imperative mood>

[optional body explaining motivation, context, and details]

[optional footer(s) for breaking changes or issue links]
```

### Types

| Type | Purpose | Example |
| :--- | :--- | :--- |
| `feat` | A new user-facing or platform feature | `feat(auth): require email verification at signup` |
| `fix` | A bug fix | `fix(assets): replace mismatched dog photo on onboarding` |
| `style` | UI/styling adjustments, themes, formatting | `style(icons): add modern svg app icons` |
| `refactor` | Code restructuring without behavioral change | `refactor(vets): extract booking state controller` |
| `perf` | Performance optimization | `perf(feed): debounce timeline scroll listener` |
| `test` | Adding or correcting tests | `test(auth): add unit tests for token expiry` |
| `docs` | Documentation updates | `docs: describe canivue canine health platform in readme` |
| `chore` | Build scripts, dependencies, project config | `chore(deps): update flutter lints to 6.0` |
| `ci` | CI/CD pipeline or workflow changes | `ci(github): add automated flutter test action` |

### Scope Guidelines

Use lowercase feature or module names that match this repository's structure:
- `auth`, `vets`, `vet_portal`, `health`, `devices`, `billing`, `community`, `search`, `design_system`, `assets`, `routing`, `deps`.

---

## 3. Workflow Steps

### Step 1: Inspect Changes
Run:
```bash
git status -s
git diff --staged # or `git diff` if not yet staged
```

Check:
1. Are there unwanted files? (e.g., build cache, temporary files, secrets)
2. Are all changes related to a single logical topic? If not, stage them separately using `git add <files>`.

### Step 2: Formulate the Commit Message
1. **Subject Line**:
   - Limit to 50–72 characters.
   - All lowercase after the prefix colon.
   - No trailing period.
2. **Body** (if non-trivial):
   - Separate from subject with a blank line.
   - Wrap at 72 characters.
   - Bullet points for multiple notable changes.
3. **Breaking Changes**:
   - Add `!` after type/scope (e.g., `feat(api)!: ...`) and/or `BREAKING CHANGE: <explanation>` in the footer.

### Step 3: Present for Confirmation
Present the proposed commit command to the user or execute if explicitly instructed:
```bash
git commit -m "<type>(<scope>): <summary>" -m "<detailed body>"
```

---

## 4. Examples in this Repo

```bash
# Feature commit
git commit -m "feat(auth): add branded splash screen that routes by session and role"

# Asset / bugfix commit
git commit -m "fix(assets): replace mismatched cat photo with a dog photo on onboarding and Buddy's avatar"

# Multi-line commit with body
git commit -m "style(icons): add modern svg app icons and android adaptive drawables" \
  -m "- Add master SVG icon, foreground, and monochrome assets in assets/icons/
- Generate Android adaptive vector drawables and mipmap PNGs
- Configure roundIcon and register assets in pubspec.yaml"
```
