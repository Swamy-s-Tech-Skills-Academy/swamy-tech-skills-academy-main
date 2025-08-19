# 04_Git-Version-Control

**Learning Level**: Beginner → Intermediate  
**Prerequisites**: Basic CLI usage, programming fundamentals  
**Estimated Time**: 2–3 hours for foundation + ongoing practice

## 🎯 Purpose

Central hub for version control learning: Git fundamentals, workflows, and collaborative development using GitHub.

## 📋 Modules & Assets

- **Workshop Agenda**: `Git-GitHub-Workshop-Agenda.md` (1-hour intro session)
- Coming Soon: Core Concepts (staging, branching, merging), Undo Strategies, Collaboration Patterns, Advanced Workflows.

## 🧠 Core Concepts (Preview)

- Distributed Version Control vs Centralized
- Repository, commit graph, HEAD pointer
- Staging area (index) & commit hygiene
- Branching strategies (feature, trunk-based, release)
- Remote synchronization (fetch, pull, push)

## 🛠️ Practical Skills

| Skill | Command Examples | Outcome |
| ----- | ---------------- | ------- |
| Initialize repo | `git init` | Start local version history |
| Configure identity | `git config --global user.name` | Proper authorship metadata |
| Stage & commit | `git add .` + `git commit -m` | Persist snapshot |
| Inspect history | `git log --oneline --graph --decorate` | Visualize commit graph |
| Branch workflow | `git switch -c feature/x` | Isolated development |
| Sync remote | `git pull --rebase` / `git push` | Up-to-date collaboration |
| Undo safely | `git restore` / `git revert` | Controlled recovery |

## 🚀 Workshop Entry Point

Start with the agenda file to deliver or self-run a structured 60‑minute introduction.

## 🧪 Suggested Micro-Evals

- Can you recover a deleted line via `git diff` + `git restore`?
- Can you resolve a simple merge conflict intentionally created?
- Can you rebase a feature branch onto updated main without losing commits?

## 📈 Progression Path

1. Intro Workshop (agenda)
2. Core Commands Deep Dive (coming soon)
3. Branching & Collaboration Patterns
4. Advanced History Rewriting (interactive rebase, squash)
5. Automation (hooks, CI integration)

## 🔗 Related Topics

- `../02_software-design-principles/` (workflow integration)
- `../../02_AI-and-ML/05_LargeLanguageModels/` (versioning prompt/eval assets)
- `../../02_AI-and-ML/07_AI-Agents/` (collaborative agent repo patterns)

---
_Status: Initial scaffold. Last Updated: 2025-08-19._
