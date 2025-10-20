# 06B_Day01_Signal_Audit

**Learning Level**: Advanced  
**Prerequisites**: Week 06 overview, access to observability, analytics, and business intelligence tools  
**Estimated Time**: 2 × 27-minute loops

## 🎯 Objectives for Today

- Audit existing signals across engineering, product, and business domains.
- Compile exemplar dossiers capturing patterns from high-performing systems.

## ⏱️ Loop Map

| Loop | Focus | Output |
| --- | --- | --- |
| 01 | Signal source audit | Signal inventory |
| 02 | Exemplar analysis | Exemplar dossier |

## 📡 Loop 01 – Signal Source Audit

**Target Output**: Signal inventory cataloging all current metrics, dashboards, and alerts.

### Step-by-step (Loop 01)

1. Extract signal lists from observability platforms (logs, metrics, traces), BI dashboards, and product analytics.
2. Tag each signal with **Owner**, **Frequency**, **Decision Supported**, and **Data Source**.
3. Note data quality issues (staleness, missing metadata, manual updates).
4. Group signals by lifecycle stage (Discover, Build, Operate, Learn).

### Signal Inventory Template

| Signal | Domain | Decision Supported | Frequency | Owner | Data Source | Quality Notes |
| --- | --- | --- | --- | --- | --- | --- |

### ASCII Grouping

```text
Discover: NPS trend, feature discovery rate
Build: Lead time, code review throughput
Operate: Error budget burn, MTTR
Learn: Experiment win rate, customer health index
```text
## 🌟 Loop 02 – Exemplar Analysis

**Target Output**: Exemplar dossier summarizing 3–4 high-performing systems and their signal practices.

### Step-by-step (Loop 02)

1. Select exemplar teams/systems recognized for disciplined measurement.
2. Document signals they rely on, how frequently they review them, and what actions follow.
3. Capture insights on tooling (dashboards, alerts, automation) that keep signals fresh.
4. Extract quotes or anecdotes illustrating why these signals matter.

### Dossier Template

| System | Signal Set | Cadence | Tooling | Impact Story | Relevance |
| --- | --- | --- | --- | --- | --- |

### Mermaid Snapshot

```mermaid
graph TD
    A(Exemplar System) --> B(Signals Used)
    B --> C(Ritual Cadence)
    C --> D(Observed Outcomes)
```text
## ✅ Exit Criteria for Day 1

- Signal inventory catalog complete with ownership and quality notes.
- Exemplar dossier highlighting actionable patterns to emulate.
- Initial shortlist of signals to evaluate for integrity tomorrow.

## 🛠️ Tools & Resources

- Observability platforms (Datadog, Grafana, Splunk).
- Business analytics suites (Power BI, Tableau, Looker).
- Executive scorecards and OKR dashboards.

## 🔄 Handoff to Day 2

- Identify signals requiring quality checks and normalization.
- Flag exemplar practices worth scaling across teams.
- Prepare data lineage questions for tomorrow’s metric integrity ledger.
