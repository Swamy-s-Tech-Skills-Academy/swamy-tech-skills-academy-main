# 02D_Day03_Metric_Engine

**Learning Level**: Advanced  
**Prerequisites**: Principle stack v0, ritual mapping matrix, analytics access  
**Estimated Time**: 2 × 27-minute loops

## 🎯 Objectives for Today

- Define leading indicators and supporting signals for each principle.
- Design the Daily Discipline Canvas layout that can be maintained in under 10 minutes daily.
- Ensure metrics can be automated or captured with minimal manual effort.

## ⏱️ Loop Map

| Loop | Focus | Output |
| --- | --- | --- |
| 05 | Metric inventory | Micro-metric catalog |
| 06 | Canvas layout | Canvas wireframe |

## 📊 Loop 05 – Metric Inventory

**Target Output**: Micro-metric catalog linking principles to measurable signals.

### Step-by-step (Loop 05)

1. For each principle, brainstorm candidate signals across **Leading**, **Lagging**, and **Health** categories.
2. Score candidates on **Signal Strength**, **Automation Feasibility**, and **Time-to-Collect** (scale 1–5).
3. Select at least one leading indicator per principle that can be refreshed daily or weekly.
4. Identify data sources (e.g., Git analytics, incident dashboards, retrospective notes) and owners.

### Metric Canvas

| Principle | Leading Signal | Lagging Signal | Health Signal | Source | Owner | Refresh Cadence |
| --- | --- | --- | --- | --- | --- | --- |

### Anti-Manual Checklist

- Avoid signals that require spreadsheet updates.
- Prefer API-accessible data.
- Automate notifications where possible (Slack bot, email digest).

## 🗂️ Loop 06 – Canvas Layout

**Target Output**: Canvas wireframe sketching the quadrant layout and update flow.

### Step-by-step (Loop 06)

1. Draft the canvas using the four quadrants: Focus, Delivery, Learning, Relationships.
2. Allocate space for **Principle Statement**, **Key Ritual**, **Metric Snapshot**, **Guardrail Reminder**.
3. Define the daily reflection prompt (e.g., “Which principle felt strained today?”).
4. Include a progress tracker for accountability partners (initials + checkboxes).

### ASCII Canvas Wireframe

```text
+---------------------------+---------------------------+
| Focus                     | Delivery                  |
| Principle:                | Principle:                |
| Ritual:                   | Ritual:                   |
| Metric Snapshot:          | Metric Snapshot:          |
| Guardrail:                | Guardrail:                |
+---------------------------+---------------------------+
| Learning                  | Relationships             |
| Principle:                | Principle:                |
| Ritual:                   | Ritual:                   |
| Metric Snapshot:          | Metric Snapshot:          |
| Guardrail:                | Guardrail:                |
+---------------------------+---------------------------+
| Daily Reflection Prompt & Accountability Tracker      |
+-------------------------------------------------------+
```text
### Mermaid Flow (Optional Render)

```mermaid
flowchart TD
    A(Metric Inventory) --> B(Canvas Quadrants)
    B --> C(Ritual Placement)
    C --> D(Metric Snapshot Tiles)
    D --> E(Reflection Prompt)
```text
## ✅ Exit Criteria for Day 3

- Micro-metric catalog complete with data source assignments.
- Canvas wireframe ready for stress testing on Day 4.
- Clear understanding of automation requirements for real signals.

## 🛠️ Tools & Resources

- Analytics dashboards (GitHub Insights, Jira velocity, PagerDuty reports).
- Diagramming or whiteboarding tool (Miro, Excalidraw, Notability).
- Automation hooks (Zapier, Power Automate, custom scripts).

## 🔄 Handoff to Day 4

- Capture open questions about metric feasibility for Day 4’s stress test.
- Prep a lightweight test scenario (e.g., “production incident + executive escalation”) for tomorrow.
- Share the wireframe with accountability partners for early feedback.
