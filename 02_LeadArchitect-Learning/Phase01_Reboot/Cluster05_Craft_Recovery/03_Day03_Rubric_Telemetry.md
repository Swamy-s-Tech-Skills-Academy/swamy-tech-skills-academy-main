# 05D_Day03_Rubric_Telemetry

**Learning Level**: Advanced  
**Prerequisites**: Micro-lab scripts, automation tooling, metric definitions  
**Estimated Time**: 2 × 27-minute loops

## 🎯 Objectives for Today

- Create assessment rubrics that clearly distinguish mastery levels.
- Plan telemetry and automation necessary to deliver fast feedback during labs.

## ⏱️ Loop Map

| Loop | Focus | Output |
| --- | --- | --- |
| 05 | Rubric creation | Assessment rubric set |
| 06 | Telemetry plan | Telemetry checklist |

## 🧮 Loop 05 – Rubric Creation

**Target Output**: Assessment rubrics with criteria for Novice, Practitioner, and Expert proficiency.

### Step-by-step (Loop 05)

1. For each lab, define evaluation dimensions (Technical Accuracy, Speed, Collaboration, Documentation).
2. Specify observable behaviors for each proficiency tier.
3. Weight dimensions to reflect business priorities (e.g., reliability over raw speed).
4. Align rubrics with Week 02 discipline metrics to reinforce shared language.

### Rubric Template

| Dimension | Novice Behavior | Practitioner Behavior | Expert Behavior | Weight |
| --- | --- | --- | --- | --- |

### ASCII Cue

```text
[Dimension] -> [Observable Behavior] -> [Weighted Score]
```text
## 📡 Loop 06 – Telemetry Plan

**Target Output**: Telemetry checklist documenting signals, tools, and automation for each lab.

### Step-by-step (Loop 06)

1. Identify automated checks (linting, unit tests, performance metrics, observability dashboards).
2. Define data capture points: start/stop times, error rates, review comments, deployment outcomes.
3. Configure feedback loops (CI notifications, Slack bots, dashboard refresh intervals).
4. Assign owners for maintaining telemetry scripts and dashboards.

### Telemetry Checklist

| Lab | Signal | Tool/Integration | Automation Hook | Owner | Refresh Cadence |
| --- | --- | --- | --- | --- | --- |

### Mermaid Signal Flow

```mermaid
flowchart LR
    L(Lab Task) --> C(Code Check)
    C --> M(Metrics Capture)
    M --> N(Notification)
    N --> F(Feedback Loop)
```text
## ✅ Exit Criteria for Day 3

- Rubrics created and aligned with business priorities.
- Telemetry checklist ready; automation owners confirmed.
- Lab scripts updated with rubric references and telemetry expectations.

## 🛠️ Tools & Resources

- CI/CD pipelines, linting tools, testing frameworks.
- Observability dashboards and analytics platforms.
- Collaboration tools for feedback (Pull requests, code review platforms).

## 🔄 Handoff to Day 4

- Share rubrics and telemetry plans with pilot participants.
- Prepare scenarios and data for rehearsal during pilot loop.
- Schedule pilot session logistics (facilitator, observers, recording).
