# 01_Templates_Toolkit

**Learning Level**: Advanced (Lead Architect Reset)  
**Prerequisites**: Phase 01 overview, awareness of signature artifacts per cluster  
**Estimated Time**: 27 minutes orientation sprint

## 🎯 Learning Objectives

By the end of this short orientation, you will:

- Understand which templates accelerate each Phase 01 artifact.
- Know when to instantiate a template and how it ties into the 10-loop cadence.
- Map templates to upstream inputs and downstream reviews for smoother hand-offs.

## 📚 Template Index

| # | Template | Use When | Primary Output |
| --- | --- | --- | --- |
| 01 | [Belief Ledger](./01_Belief-Ledger.md) | Cluster 01 – Loop 01 | Inventory of legacy vs. future beliefs with evidence |
| 02 | [Daily Discipline Canvas](./02_Daily-Discipline-Canvas.md) | Cluster 02 – Loop 06 | Structured canvas covering rituals, metrics, safeguards |
| 03 | [Toolchain Manifesto](./03_Toolchain-Manifesto.md) | Cluster 03 – Loop 09 | Narrative manifesto with principles, roadmap, and enablement |
| 04 | [Systems Heuristic Entry](./04_Systems-Heuristic-Entry.md) | Cluster 04 – Loop 09 | Reusable card capturing heuristics, signals, and bias checks |
| 05 | [Foundations Lab Journal](./05_Foundations-Lab-Journal.md) | Cluster 05 – Loop 09 | Progressive lab log with rubrics, telemetry, and reflections |
| 06 | [Signal Inventory](./06_Signal-Inventory.md) | Cluster 06 – Loop 01 | Catalog of signals, integrity scores, and owners |
| 07 | [Guardrail Charter Skeleton](./07_Guardrail-Charter.md) | Cluster 07 – Loop 09 | Baseline guardrail charter with enforcement design |
| 08 | [Exploration Experiment Charter](./08_Exploration-Experiment-Charter.md) | Cluster 08 – Loop 03 | Charter capturing hypothesis, guardrails, metrics, runway |
| 09 | [Exploration Storyboard](./09_Exploration-Storyboard.md) | Cluster 08 – Loop 09 | Portfolio storyboard and go/no-go tracker |
| 10 | [Reboot Doctrine Outline](./10_Reboot-Doctrine.md) | Cluster 09 – Loop 09 | Executive-ready doctrine outline with measurement plan |

## 🛠️ How to Use the Toolkit

1. **Clone the template** into your working notes (or duplicate in-place if you are iterating within this repository).
2. **Fill only the relevant sections** during each loop; resist the urge to complete the entire template on day one.
3. **Link back to source evidence** (signals, retrospectives, dashboards) to keep artifacts auditable.
4. **Capture review feedback** inline using `> Reviewer Notes` blocks to preserve deltas.
5. **Version each artifact** (v0.7, v0.9, v1.0) aligning with the 10-loop rhythm before publishing.

## 🔄 Cross-Cluster Dependencies

- The **Belief Ledger** feeds directly into the Daily Discipline Canvas (principles) and Toolchain Manifesto (tooling assumptions).
- The **Signal Inventory** powers the Guardrail Charter, Exploration Experiment Charter, and Doctrine measurement chapter.
- The **Foundations Lab Journal** supplies anecdotes and telemetry referenced in the Reboot Doctrine.

## ✅ Quality Gate Reminder

Run `npx markdownlint-cli2 "02_LeadArchitect-Learning/Phase01_Reboot/**/*.md"` and your preferred link-check routine after customizing templates to ensure compliance with STSA authoring standards.

## 🔗 Related Topics

- `../README.md`
- `../Cluster01_Reorient_Mindset/00_Week01_Mindset_Reorientation.md`
- `../../01_ReferenceLibrary/01_Development/Development-Track-Restructuring-Summary.md`
