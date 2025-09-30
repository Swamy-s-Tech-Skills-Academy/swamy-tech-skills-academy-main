# 04C_Day02_Constraint_Forge

**Learning Level**: Advanced  
**Prerequisites**: System landscape canvas, feedback loop inventory, resource/utilization data  
**Estimated Time**: 2 × 27-minute loops

## 🎯 Objectives for Today

- Identify governing constraints hindering flow and scalability across systems.
- Draft heuristics that help teams navigate complexity quickly and consistently.

## ⏱️ Loop Map

| Loop | Focus | Output |
| --- | --- | --- |
| 03 | Constraint analysis | Constraint ledger |
| 04 | Heuristic drafting | Heuristic set v0 |

## 🔒 Loop 03 – Constraint Analysis

**Target Output**: Constraint ledger cataloging limiting factors and leverage strategies.

### Step-by-step (Loop 03)

1. Analyze the landscape and loops to spot bottlenecks (resource, policy, market, technical debt).
2. For each constraint, record impact on flow, affected systems, and severity.
3. Determine current mitigations and whether they are sustainable.
4. Identify potential leverage points (automations, org changes, architectural shifts).

### Ledger Template

| Constraint | Category | Impacted System(s) | Severity (1–5) | Current Mitigation | Leverage Option |
| --- | --- | --- | --- | --- | --- |

### ASCII Snapshot

```text
Constraint: Build Pipeline Throughput
Category: Resource
Impact: Release Frequency ↓
Mitigation: Nightly batches (fragile)
Leverage: Parallel pipelines + additional runners
```

## 🧠 Loop 04 – Heuristic Drafting

**Target Output**: Heuristic set v0 comprising 8–10 crisp decision shortcuts.

### Step-by-step (Loop 04)

1. Convert constraints and leverage options into “If/Then/Because” heuristics.
2. Ensure each heuristic aligns with Week 02 discipline principles and toolchain capabilities.
3. Pair each heuristic with a **Signal to Watch** and a **Bias Warning**.
4. Vet language for clarity; a frontline team should understand it without extra context.

### Heuristic Template

```text
Heuristic:
If: (condition)
Then: (action)
Because: (system rationale)
Signal to Watch:
Bias Warning:
```

### ASCII Flow

```text
[Constraint] -> [Leverage Insight] -> [Heuristic Draft] -> [Signal/Bias Pairing]
```

## ✅ Exit Criteria for Day 2

- Constraint ledger populated with high-impact bottlenecks and leverage ideas.
- Heuristic set v0 drafted with signals and bias warnings.
- Shortlist of heuristics requiring scenario validation tomorrow.

## 🛠️ Tools & Resources

- Throughput and utilization dashboards, OKR/KPI reports.
- Lean/TOC reference materials for constraint categories.
- Past postmortems highlighting decision breakdowns.

## 🔄 Handoff to Day 3

- Highlight heuristics needing scenario testing and bias audits.
- Share constraint ledger with platform teams for feasibility input.
- Prep scenario storylines (incident, scaling event, strategic pivot) for tomorrow’s simulations.
