# Reference Library Taxonomy Map

> See also: [README](README.md) · [INDEX](INDEX.md) · [ORGANIZATION_GUIDE](ORGANIZATION_GUIDE.md)

> When to edit this file: Add/rename canonical tags and concept codes. Don’t invent ad‑hoc tags in pages—define them here first.

**Purpose**: Canonical concept classification + prerequisite layering.
**Last Updated**: 2025-08-20
**Status**: Draft

## Legend

- Level: B (Beginner), I (Intermediate), A (Advanced)
- Status: Stub | Draft | Complete

## Development Track

| Code | Concept | Level | Status | Prerequisites |
|------|---------|-------|--------|---------------|
| DEV-PY-001 | Python Syntax & Flow | B | Complete | None |
| DEV-PY-002 | Data Structures & Mutability | B | Draft | DEV-PY-001 |
| DEV-PY-010 | Virtual Environments & Tooling | I | Stub | DEV-PY-001 |
| DEV-GIT-001 | Git Core Objects | B | Draft | None |
| DEV-GIT-002 | Branching Strategies | I | Stub | DEV-GIT-001 |
| DEV-GIT-003 | Undo & Recovery | I | Stub | DEV-GIT-001 |
| DEV-GIT-004 | History Rewriting | A | Stub | DEV-GIT-003 |
| DEV-DES-001 | SOLID Principles | I | Draft | DEV-PY-002 |
| DEV-DES-010 | Patterns Catalog Intro | I | Stub | DEV-DES-001 |

## AI & ML Track

| Code | Concept | Level | Status | Prerequisites |
|------|---------|-------|--------|---------------|
| AI-FND-001 | AI vs ML vs DL | B | Draft | None |
| ML-ALG-001 | Supervised Learning Overview | B | Stub | AI-FND-001 |
| ML-ALG-010 | Model Evaluation Metrics | I | Stub | ML-ALG-001 |
| DL-FND-001 | Neural Network Basics | B | Stub | ML-ALG-001 |
| NLP-FND-001 | Tokenization Techniques | B | Stub | ML-ALG-001 |
| NLP-EMB-001 | Embeddings Evolution | I | Stub | NLP-FND-001 |
| LLM-LIF-001 | Prompt Patterns | I | Stub | NLP-EMB-001 |
| LLM-LIF-002 | RAG Architecture | I | Stub | LLM-LIF-001 |
| LLM-LIF-003 | LLM Evaluation & Guardrails | I | Stub | LLM-LIF-001 |
| AGT-ARC-001 | Agent Architectural Patterns | I | Stub | LLM-LIF-002 |
| MCP-SRV-001 | MCP Server Fundamentals | I | Stub | LLM-LIF-002 |

## Data Science Track

| Code | Concept | Level | Status | Prerequisites |
|------|---------|-------|--------|---------------|
| DS-MTH-001 | Statistical Foundations (External Anchor) | B | Stub | None |
| DS-METH-001 | CRISP-DM vs OSEMN | B | Stub | DS-MTH-001 |
| DS-ANL-001 | Exploratory Data Analysis | B | Stub | DS-MTH-001 |
| DS-BIG-001 | Lakehouse & Medallion | I | Stub | DS-METH-001 |
| DS-GOV-001 | Data Governance & Lineage | I | Stub | DS-METH-001 |

## Cross-Cutting

| Code | Concept | Level | Status | Prerequisites |
|------|---------|-------|--------|---------------|
| X-GOV-001 | AI Ethics & Governance Integration | I | Draft | AI-FND-001 |
| X-SEC-001 | Secure Development Lifecycle | I | Stub | DEV-PY-002 |
| X-OBS-001 | Observability Foundations | I | Stub | DEV-GIT-001 |
| X-AUTO-001 | CI/CD & Deployment Pipelines | I | Stub | DEV-GIT-001 |

## Roadmap Notes

- Promote stubs to draft in priority order: Git Branching, ML Supervised Overview, Tokenization, Prompt Patterns.
- Add IDs to file headers to match codes for future automation.

## Update Workflow

1. Add row → create stub file with matching code in header.
2. Ensure forward/backward links.
3. Increment progress dashboard in `INDEX.md`.
