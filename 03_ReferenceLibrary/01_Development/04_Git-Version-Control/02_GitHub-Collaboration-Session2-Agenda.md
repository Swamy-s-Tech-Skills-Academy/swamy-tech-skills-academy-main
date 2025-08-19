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
_Status: Initial draft for Session 2. Pending future linkage to advanced modules (branch protection, Actions, security)._
