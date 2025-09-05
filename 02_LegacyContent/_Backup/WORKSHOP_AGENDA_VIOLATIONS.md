# WORKSHOP AGENDA VIOLATIONS - STSA NON-COMPLIANT CONTENT

**Date Moved**: September 5, 2025  
**Reason**: Workshop agenda format violates STSA educational content policy  
**Action**: Moved from Reference Library, requires transformation to educational content  
**Files**: 2 workshop agenda files from Git Version Control section

---

## ❌ VIOLATION 1: Git GitHub Workshop Agenda

**Original Location**: `01_ReferenceLibrary/01_Development/04_Git-Version-Control/01_Git-GitHub-Workshop-Agenda.md`  
**Issue**: Workshop session structure with timing (5 min, 10 min, 15 min blocks)  
**STSA Policy Violation**: Training agenda format rather than educational reference content

**Content:**

---

# Introduction to Git and GitHub — 1-Hour Workshop Agenda

**Audience:** Beginners, practitioners new to version control or GitHub  
**Duration:** 1 hour  
**Source:** Consolidated from Microsoft Learn modules and best practices

---

## 📅 Session Agenda (1 Hour)

**Title:** *Introduction to Git, and GitHub*

### 1. Welcome & Session Overview (5 min)

- Trainer introduction
- Purpose of the session
- Quick poll: participants' prior knowledge of Git/GitHub

---

### 2. Introduction to Git (Version Control Basics) (10 min)

- What is Version Control? Why it matters
- Centralized vs Distributed VCS
- Introduction to Git as the most popular DVCS

---

### 3. Hands-on with Git Basics (15 min)

- Creating a new Git repository (`git init`)
- Configuring Git (`git config`)
- Tracking changes (`git add`, `git commit`)
- Viewing history (`git log`)
- Recovering from mistakes (`git checkout`, `git reset`)

---

### 4. Introduction to GitHub (10 min)

- What is GitHub?
- GitHub as a collaborative platform
- Key features: Repositories, Issues, Pull Requests, Discussions

---

### 5. GitHub Flow in Action (15 min)

- Cloning a repo (`git clone`)
- Branching & making commits (`git branch`, `git checkout`, `git commit`)
- Pushing changes to GitHub (`git push`)
- Creating a Pull Request and merging changes

---

### 6. Wrap-up & Q&A (5 min)

- Summary of key takeaways
- Common next steps (practice, resources, GitHub learning paths)
- Questions from participants

---

> This structure keeps **30 min for Git**, **25 min for GitHub**, and **5 min buffer** for wrap-up/Q&A.

---

## ❌ VIOLATION 2: GitHub Collaboration Session Agenda

**Original Location**: `01_ReferenceLibrary/01_Development/04_Git-Version-Control/02_GitHub-Collaboration-Session2-Agenda.md`  
**Issue**: Session 2 agenda with learning objectives in workshop format  
**STSA Policy Violation**: Training session structure rather than educational reference content

**Content:**

---

# Session 2 — Getting Started with GitHub: Collaboration, Management, and Hands-on Practice

**Learning Level:** Beginner → Early Practitioner  
**Prerequisites:** Basic Git (init, add, commit, branch, push), attended Session 1 or equivalent  
**Duration:** 60 minutes  
**Session Type:** Demo + Guided Practice  
**Last Updated:** 2025-08-19

---

## 🎯 Learning Objectives (What Participants Will Be Able To Do)

By the end of this session, participants can:

1. Explain how GitHub enables collaborative workflows (issues → branches → PRs → merge).
2. Configure basic repository settings (visibility, collaborators, branch protection awareness).
3. Navigate core UI areas: Code, Issues, Pull Requests, Actions, Insights.
4. Use GitHub Desktop to clone, commit, and sync changes without the CLI.
5. Complete a minimal Pull Request workflow (branch, change, PR, review, merge) end-to-end.
6. Identify next-step resources for deeper learning (Actions, Discussions, Project boards).

---

## 🧾 Session Agenda (1 Hour)

### 1. GitHub as a Collaborative Platform (10 min)

- Overview of GitHub's role in modern development ecosystems
- Collaboration surfaces: Issues, Discussions, Pull Requests
- Transparency & audit trail (commit history, review metadata)

### 2. GitHub Platform Management (10 min)

- Repository types: public vs private (when to choose which)
- Access control basics (collaborators vs forks)
- Notifications, watching, and subscription hygiene
- Mention branch protection (teaser for future session)

### 3. Exercise – Guided Tour of GitHub (10 min)

- Live walkthrough: repo home → code view → commit diff → branches
- Explore Issues: labels, assignees, commenting
- Pull Requests: conversation tab vs commits vs files changed

### 4. GitHub Desktop (10 min)

- Install & first-run setup (sign-in, cloning a repo)
- Visual diff & staging chunks (partial commit mindset)
- Sync (fetch/pull) vs push — clarifying directionality

### 5. Live Demo – Pull Request Workflow (15 min)

Workflow Demonstrated:

1. Create a feature branch (Desktop or CLI)  
2. Make a small change (e.g., edit README)  
3. Commit with a convention (feat/docs chore)  
4. Push branch → open Pull Request  
5. Add description + reference an issue (if any)  
6. Reviewer comment + update commit (amend or follow-up commit)  
7. Merge (squash vs merge commit rationale)  
8. Delete branch and confirm main updated

### 6. Wrap-up & Q&A (5 min)

- Recap: Collaboration surfaces + PR flow + Desktop utility
- Highlight next exploration areas: Actions, Projects, Codespaces
- Provide resource list (GitHub Docs, Microsoft Learn paths)

---

## 🧪 Quick Success Checks (Facilitator Prompts)

| Check | Prompt | Target Outcome |
| ----- | ------ | -------------- |
| UI Navigation | "Open the latest commit diff" | Participant reaches commit view quickly |
| Branching | "Show me your new branch locally" | Local branch exists & tracked |
| PR Creation | "Paste your PR URL" | PR created with description |
| Review Response | "Apply suggested change & push" | Update appears in PR timeline |
| Merge Choice | "Why choose squash here?" | Can articulate clean history benefit |

---

## 🧩 Optional Stretch (If Ahead of Time)

- Add a CODEOWNERS file and open a PR to show automatic reviewer assignment
- Enable Discussions and create a starter topic
- Create a draft PR to illustrate early feedback workflows

---

## 📚 Suggested Resources

| Topic | Resource |
| ----- | -------- |
| Git Basics | (Session 1 Agenda) |
| PR Best Practices | GitHub Docs → Pull Requests Guide |
| Branching Strategies | Future session / internal guide (coming soon) |
| GitHub Desktop | Official GitHub Desktop Docs |
| Automation | GitHub Actions Quickstart (future module) |

---

## 🔗 Related Internal Content

- `01_Git-GitHub-Workshop-Agenda.md` (Session 1)  
- `../02_software-design-principles/` (code review quality & structure)  
- `../../02_AI-and-ML/07_AI-Agents/` (collaborative experimentation patterns)

---
*Status: Initial draft for Session 2. Pending future linkage to advanced modules (branch protection, Actions, security).*

---

## 🎯 TRANSFORMATION REQUIREMENTS

These workshop agendas need to be transformed into STSA-compliant educational content:

### **Required Changes:**

1. **Remove workshop structure**: Eliminate session timing, facilitator prompts, agenda format
2. **Create educational content**: Transform into conceptual guides with learning progressions
3. **Add STSA methodology**: Include original examples, educational scaffolding, cross-references
4. **Focus on concepts**: Git fundamentals, GitHub collaboration patterns, branching strategies

### **Suggested New Files:**

- `01_Git-Fundamentals-and-Version-Control.md` - Core Git concepts and workflows
- `02_GitHub-Collaboration-Workflows.md` - Collaborative development patterns and best practices

These should follow STSA educational content standards with clear learning objectives, progressive scaffolding, and original explanations rather than workshop format.
