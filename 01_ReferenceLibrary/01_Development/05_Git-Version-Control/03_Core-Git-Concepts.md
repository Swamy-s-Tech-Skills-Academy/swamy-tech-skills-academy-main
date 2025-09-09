# 03 Core Git Concepts

**Learning Level:** Beginner → Practitioner  
**Prerequisites:** Basic command line familiarity, understanding of file versioning concepts  
**Estimated Time:** 45–60 minutes focused study + practice reps

---

## 🎯 Learning Objectives

By the end you will be able to:

1. Describe Git's data model (blobs, trees, commits, refs) and how the commit graph forms history.
2. Explain the working directory, staging area (index), and repository (object database) separation.
3. Create, switch, and merge branches while interpreting fast-forward vs true merge commits.
4. Use `git diff` variants to inspect unstaged, staged, and committed changes.
5. Perform safe undo operations (restore, revert, reset --soft / --mixed) with a decision heuristic.
6. Visualize history with graph flags and interpret parent relationships.

---

## 🧩 Conceptual Foundation

| Concept | What It Is | Mental Model | Key Commands |
| ------- | ---------- | ------------ | ------------ |
| Object Store | Content-addressable DB of blobs/trees/commits | Immutable snapshots | (implicit) |
| Blob | File contents snapshot | Leaf node | (created via add/commit) |
| Tree | Directory structure mapping names → blobs/trees | Folder node | (built during commit) |
| Commit | Metadata + root tree + parents | Node in DAG | `git commit` |
| Ref | Human-readable pointer to a commit | Named bookmark | `git branch`, `git tag` |
| HEAD | Current ref (or detached commit) | "You are here" marker | `git switch`, `git checkout` |
| Index (Staging) | Proposed next commit snapshot | Draft staging area | `git add`, `git restore --staged` |

### Working Directory, Index, HEAD

```text
[Working Dir] --(git add)--> [Index] --(git commit)--> [HEAD commit]
               ^                               |
               |--(git restore)----------------|
```

Common inspections:

- Unstaged vs HEAD: `git diff`
- Staged vs HEAD: `git diff --cached`
- Working vs Index: (stage change then modify again; inspect with above two)

### Commit Graph & History

```text
A---B---C (main)
     \
      D---E (feature)
```

- Fast-forward merge: main at C, merge feature → move ref to E (no new commit) if linear.
- True (3-way) merge: divergent tips both advanced → creates new merge commit with two parents.

Visual helpers:

- `git log --oneline --graph --decorate --all -n 12`
- `git show <commit>` (content + metadata)
- `git cat-file -t/-p <hash>` (low-level inspection)

### Branch Operations

| Action | Command | Notes |
| ------ | ------- | ----- |
| Create & switch | `git switch -c feature/x` | Preferred over legacy checkout |
| Switch existing | `git switch feature/x` | Updates HEAD ref |
| List branches | `git branch --all --verbose` | Shows tracking info |
| Delete merged | `git branch -d feature/x` | Safe (refuses if unmerged) |
| Force delete | `git branch -D feature/x` | Use with caution |

### Diffs & Staging Granularity

Partial staging keeps commits focused:

- `git add -p` (interactive hunks)
- GUI chunk staging (Desktop / IDE) mirrors concept
- Amend last commit (no published): `git commit --amend` (updates commit hash)

### Safe Undo Matrix

| Goal | Recommended Command | Why |
| ---- | ------------------- | --- |
| Unstage file | `git restore --staged <file>` | Keeps working changes |
| Discard local edits | `git restore <file>` | Revert to HEAD version |
| New commit to negate prior | `git revert <hash>` | Preserves history (public safe) |
| Move branch pointer only | `git reset --soft <hash>` | Keep index & working tree |
| Uncommit but keep changes | `git reset --mixed <hash>` | Default; changes now unstaged |
| Dangerous rewrite | `git reset --hard <hash>` | Nuke uncommitted/staged changes |

Heuristic:

1. Public/shared? Prefer `revert`.
2. Need content retained? Avoid `--hard`.
3. Only last commit message wrong? `--amend`.

### Fast-Forward vs Merge Example

```text
# Assume on main
git merge feature/linear   # Fast-forward → pointer moves

# Divergent history
# main:    A---B---C
# feature: A---B---D---E
# On main:
git merge feature          # Creates merge commit M with parents C,E
```

### Detached HEAD Note

```text
HEAD -> <hash>
```

Occurs when checkout a specific commit. Create a branch to save work: `git switch -c experiment`.

---

## 🛠️ Practical Exercises

| Exercise | Action | Success Criteria |
| -------- | ------ | ---------------- |
| Inspect graph | Run log graph command | See decorated graph of branches |
| Partial stage | Edit file, stage hunks | Commit contains only intended lines |
| Safe revert | Introduce bug, revert commit | New commit undoes change |
| Soft reset | Make 2 commits, soft reset 1 back | Changes staged & intact |
| Merge scenario | Create divergence & merge | Merge commit or fast-forward understood |

---

## ❗ Common Pitfalls

| Pitfall | Symptom | Avoidance |
| ------- | ------- | --------- |
| Overstuffed commits | Hard to review | Stage selectively; commit thematic units |
| Using reset on shared history | Teammates see rewrites | Use revert for published commits |
| Hard reset panic | Lost unstaged work | Backup with `git stash` before risky ops |
| Detached HEAD edits lost | Work disappears after switch | Create branch before switching |
| Blind merge conflicts | Confusing conflict markers | Create small, frequent branches |

---

## 🔄 Next Steps

1. Practice interactive staging (`git add -p`).
2. Learn conflict resolution strategies (upcoming module).
3. Explore reflog for deeper recovery (`git reflog`).
4. Prepare for branching strategy patterns (feature vs trunk-based).

---
_Status: Initial draft. To be refined with diagrams for reflog & rebasing in advanced modules. Last Updated: 2025-08-19._
