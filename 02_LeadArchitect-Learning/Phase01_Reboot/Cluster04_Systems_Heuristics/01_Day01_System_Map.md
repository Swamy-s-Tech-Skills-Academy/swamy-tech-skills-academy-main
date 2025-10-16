# 04B_Day01_System_Map

**Learning Level**: Advanced  
**Prerequisites**: Week 04 overview, portfolio list of products/platforms, observability dashboards  
**Estimated Time**: 2 × 27-minute loops

## 🎯 Objectives for Today

- Build a high-level system landscape canvas covering critical products, platforms, and dependencies.
- Inventory reinforcing and balancing feedback loops that drive performance.

## ⏱️ Loop Map

| Loop | Focus | Output |
| --- | --- | --- |
| 01 | System landscape mapping | System landscape canvas |
| 02 | Feedback loop discovery | Feedback loop inventory |

## 🌐 Loop 01 – System Landscape Mapping

**Target Output**: System landscape canvas summarizing domains, interfaces, and key metrics.

### Step-by-step (Loop 01)

1. List all major systems (customer-facing apps, APIs, data platforms, shared services) and their primary purpose.
2. Identify upstream/downstream dependencies, including third-party integrations and shared infrastructure.
3. Annotate each system with owner, gold metric (e.g., latency, availability), and data classification.
4. Visualize interactions using a layered diagram (experience, services, data, infrastructure).

### Canvas Template

| Layer | Systems | Owner | Gold Metric | Dependencies |
| --- | --- | --- | --- | --- |

### ASCII Landscape Sketch

```text
[Experience Layer]
   |-- Mobile App
   |-- Web Portal
        |
[Service Layer]
   |-- API Gateway -> Order Service -> Payment Service
   |-- Notification Service
        |
[Data Layer]
   |-- Event Stream -> Data Lake -> Analytics
        |
[Infrastructure]
   |-- Kubernetes -> Observability Stack -> Identity Provider
```

## 🔁 Loop 02 – Feedback Loop Discovery

**Target Output**: Feedback loop inventory highlighting reinforcing (R) and balancing (B) loops.

### Step-by-step (Loop 02)

1. For each system, identify signals that amplify outcomes (R loops) or stabilize performance (B loops).
2. Document causes, effects, and delays (time lag between action and impact).
3. Mark loops that cross team boundaries (architecture, product, ops) for alignment discussions.
4. Highlight loops that currently lack instrumentation or have blind spots.

### Inventory Table

| Loop Name | Type (R/B) | Trigger | Effect | Delay | Owner | Instrumentation Gap |
| --- | --- | --- | --- | --- | --- | --- |

### ASCII Loop Notation

```text
R1: Feature Velocity -> Customer Adoption -> Feedback Volume -> Prioritized Roadmap -> Feature Velocity
B1: Error Rate -> Incident Response -> Mitigation -> Error Rate
```

## ✅ Exit Criteria for Day 1

- System landscape canvas completed with major systems and dependencies.
- Feedback loop inventory listing at least three reinforcing and two balancing loops.
- Insight list noting areas lacking observability or owner clarity.

## 🛠️ Tools & Resources

- Architecture repository diagrams, CMDB entries, value stream maps.
- Observability dashboards (Grafana, Datadog, New Relic) for signal discovery.
- Product performance reports and customer feedback summaries.

## 🔄 Handoff to Day 2

- Capture questions about constraints (resource, policy) for tomorrow’s ledger.
- Flag loops requiring metric or alert investments for the automation backlog.
- Share canvas draft with domain leads to validate accuracy before Day 2.
