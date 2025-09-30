# 03B_Day01_Portfolio_Scan

**Learning Level**: Advanced  
**Prerequisites**: Tool inventory exports, finance/license reports, Week 03 overview  
**Estimated Time**: 2 × 27-minute loops

## 🎯 Objectives for Today

- Build a consolidated tool portfolio snapshot with adoption, spend, and owner visibility.
- Map critical workflows to understand where friction and duplication exist.

## ⏱️ Loop Map

| Loop | Focus | Output |
| --- | --- | --- |
| 01 | Portfolio heatmap | Tool portfolio snapshot |
| 02 | Workflow mapping | Flow impediment map |

## 🗂️ Loop 01 – Portfolio Heatmap

**Target Output**: Tool portfolio snapshot capturing adoption, spend, and lifecycle stage.

### Step-by-step (Loop 01)

1. Pull data from procurement, enterprise architecture, and shadow IT trackers to list every tool in use.
2. For each tool, log **Primary Persona**, **Use Case**, **Cost**, **Adoption Level** (High/Medium/Low), and **Lifecycle Stage** (Pilot, Standard, Legacy).
3. Highlight duplicates serving the same capability or persona.
4. Visualize the result using a simple heatmap (adoption vs. value).

### Snapshot Table

| Tool | Persona | Use Case | Adoption | Value | Cost Tier | Owner |
| --- | --- | --- | --- | --- | --- | --- |

### ASCII Heatmap

```text
Value →
Adoption ↓   Low            Medium         High
High         [Tool]         [Tool]         [Tool]
Medium       [Tool]         [Tool]         [Tool]
Low          [Tool]         [Tool]         [Tool]
```

## 🔍 Loop 02 – Workflow Mapping

**Target Output**: Flow impediment map showing where tools support or obstruct critical workflows.

### Step-by-step (Loop 02)

1. Choose 3–4 mission-critical workflows (e.g., feature from idea to production, incident response, compliance audit).
2. Diagram each workflow including handoffs, data transitions, and the tool(s) used at each step.
3. Note friction points: manual copy-paste, missing integrations, slow approvals, or data silos.
4. Flag high-risk gaps (security, audit, data residency) and quick wins.

### Workflow Map Template

```text
[Trigger] -> [Tool A] -> [Hand-off] -> [Tool B] -> [Decision] -> [Tool C] -> [Outcome]
                 ^            Issues? (Y/N)          ^            Friction?
```

### Checklist

- [ ] At least one workflow per persona (architect, engineer, SRE).
- [ ] Friction points labeled.
- [ ] Quick wins identified for automation backlog.

## ✅ Exit Criteria for Day 1

- Portfolio snapshot populated with adoption and cost data.
- Flow impediment map highlighting at least three pain points.
- Insights ready to fuel Day 2 principle and capability mapping.

## 🛠️ Tools & Resources

- Procurement/license systems (Coupa, ServiceNow, spreadsheets).
- Architecture diagrams and value stream maps.
- Interviews with platform leads or DevOps engineers.

## 🔄 Handoff to Day 2

- Capture questions for Day 2 on what “good” tool behavior should look like.
- Bring heatmap and flow maps as evidence for principle crafting.
- Note systems that repeatedly appear in friction zones for deeper inspection.
