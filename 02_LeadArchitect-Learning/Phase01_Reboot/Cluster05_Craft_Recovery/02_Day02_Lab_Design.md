# 05C_Day02_Lab_Design

**Learning Level**: Advanced  
**Prerequisites**: Craft gap matrix, priority heatmap, sample repositories/data sets  
**Estimated Time**: 2 × 27-minute loops

## 🎯 Objectives for Today

- Establish design principles that make craft labs realistic, scalable, and reusable.
- Draft micro-lab scripts for each prioritized skill.

## ⏱️ Loop Map

| Loop | Focus | Output |
| --- | --- | --- |
| 03 | Lab design principles | Lab guideline charter |
| 04 | Exercise drafting | Micro-lab scripts |

## 🧱 Loop 03 – Lab Design Principles

**Target Output**: Lab guideline charter outlining standards for all exercises.

### Step-by-step (Loop 03)

1. Translate prioritized skill gaps into design goals (e.g., “Improve unit test reliability under time pressure”).
2. Define lab attributes: **Duration**, **Difficulty Levels**, **Real-world Constraints**, **Required Tooling**.
3. Set facilitation standards (solo vs. pair vs. mob, feedback cadence, scoring expectations).
4. Document safety nets (sample solutions, hints, AI copilot guardrails).

### Charter Snapshot

| Attribute | Guideline |
| --- | --- |
| Duration | 2 × 27-minute loops per lab |
| Difficulty | Ramp from baseline to edge-case challenges |
| Tooling | Must use production-aligned stack |
| Feedback | Automated tests + facilitator debrief |

### ASCII Reminder

```text
[Skill Gap] -> [Design Goal] -> [Lab Attribute] -> [Facilitation Rule]
```text
## 🧪 Loop 04 – Exercise Drafting

**Target Output**: Micro-lab scripts (one per priority skill).

### Step-by-step (Loop 04)

1. For each skill, craft scenario narrative, datasets/code artifacts, and expected outcomes.
2. Include **Setup Instructions**, **Task Steps**, **Success Criteria**, **Stretch Goals**.
3. Plan integration with automation backlog items (CI check, lint rule, observability hook).
4. Validate lab relevance with subject matter experts.

### Micro-Lab Script Template

```text
Lab Name:
Skill Targeted:
Scenario Narrative:
Prerequisites:
Setup Steps:
Core Tasks:
Success Criteria:
Stretch Work:
Debrief Prompts:
```text
### Mermaid Lab Flow

```mermaid
flowchart TD
    S(Setup) --> T(Tasks)
    T --> A(Automation Checks)
    A --> D(Debrief)
    D --> L(Learnings Captured)
```text
## ✅ Exit Criteria for Day 2

- Lab guideline charter approved with facilitation standards.
- Draft micro-lab scripts created for each priority skill.
- SMEs enlisted for review before rubric creation tomorrow.

## 🛠️ Tools & Resources

- Sample repositories aligned to production stack.
- Testing frameworks and automation scripts.
- Subject matter experts for validation.

## 🔄 Handoff to Day 3

- Prepare to build rubrics and telemetry plans anchored in today’s scripts.
- Collect automation hooks or dashboards required to measure lab performance.
- Schedule SME review sessions to coincide with rubric drafting.
