# 02_Complete-Design-Principles-Guide

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: OOP Fundamentals, SOLID Parts 1-5 (overview)  
**Estimated Time**: Part 1 of N — 27 minutes

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

1. See how SOLID fits within broader design principles
2. Apply SOLID alongside cohesion, coupling, and layering
3. Recognize trade-offs and when principles conflict
4. Use decision checklists during reviews and designs

## 📋 Quick Overview (5 minutes)

This guide consolidates foundational software design principles (SOLID, DRY, KISS, YAGNI, cohesion/coupling, composition-over-inheritance) into a practical field manual for architects and senior engineers.

```text
Design Principles Map
├─ SOLID (object design)
│  ├─ SRP (reason to change)
│  ├─ OCP (extension vs modification)
│  ├─ LSP (behavioral contracts)
│  ├─ ISP (client-specific interfaces)
│  └─ DIP (abstractions over details)
├─ Cohesion & Coupling (module design)
├─ Composition over Inheritance
├─ DRY / KISS / YAGNI
└─ Architectural Boundaries (layers, hexagonal)
```

## 🔍 Core Concepts (15 minutes)

### 1) Cohesion and Coupling — The Macro Lens

- Cohesion: how strongly the responsibilities of a module relate to each other
- Coupling: how dependent a module is on others (aim for low, but not zero)
- Heuristics: instability points, ripple effects, change amplification

### 2) Composition Over Inheritance

- Prefer composing behavior from small parts to deep class hierarchies
- Benefits: flexibility, testability, OCP/DIP synergy
- Pitfalls: over-abstraction, accidental complexity

### 3) When Principles Conflict

- OCP vs YAGNI: extendability vs not building ahead
- SRP vs Cohesion: too many small classes vs unclear boundaries
- ISP vs Simplicity: interface granularity vs usability

### 4) Review Checklists (Leader-Friendly)

- Responsibility: can we state it in one sentence without “and/or”?
- Extension path: how would we add a new variant without modifying core?
- Substitutability: what behavioral contract must never change?
- Interfaces: which clients depend on each method?
- Abstractions: are high-level modules free of infrastructure details?

## 🛠️ Practical Implementation (5 minutes)

- Introduce “Principle Cards” in PR templates (SRP/OCP/LSP/ISP/DIP prompts)
- Adopt policy-based composition (strategies/features as policies)
- Define contracts with tests (contract/invariant suites)
- Use dependency boundaries (ports/adapters) for infrastructure

## ✅ Key Takeaways & Next Steps (2 minutes)

- Principles are tools, not laws — optimize for clarity and change cost
- Favor composition, explicit contracts, and abstraction boundaries
- Next: Deep dives on patterns that implement these principles

## 🔗 Related Topics

### Prerequisites

- [SOLID Principles Track](01_SOLID-Principles-Track.md)

### Builds Upon

- [01: Single Responsibility](01_SOLID-Part1-Single-Responsibility.md)
- [02: Open/Closed](02_SOLID-Part2-Open-Closed-Principle.md)
- [03: Liskov Substitution](03_SOLID-Part3-Liskov-Substitution-Principle.md)
- [04: Interface Segregation](04_SOLID-Part4-Interface-Segregation-Principle.md)
- [05: Dependency Inversion](05_SOLID-Part5-Dependency-Inversion-Principle.md)

### Enables

- Design patterns selection and mapping
- Architecture patterns (clean/hexagonal)

### Cross-References

- [Deep Dive Analysis](04_SOLID-Principles-Deep-Dive.md)

---

## 📚 STSA Metadata

```yaml
module: complete-design-principles-guide
track: Development
category: Software Design Principles
level: Intermediate-Advanced
duration: 27 minutes
updated: 2025-10-05
status: Active
```
