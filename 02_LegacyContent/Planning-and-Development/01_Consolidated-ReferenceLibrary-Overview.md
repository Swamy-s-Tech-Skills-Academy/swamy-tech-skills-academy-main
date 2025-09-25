<!-- STSA metadata: Level: Professional | Time: 27 minutes | Part: Consolidation -->
# Reference Library Consolidated Overview

Learning Level: Professional

Estimated Time: 27 minutes (read)

Purpose: This file consolidates strategy, migration history, and next-steps guidance previously spread across several ReferenceLibrary documents so maintainers and contributors have a single authoritative view.

Files consolidated:

- `200-Line-Format-Conversion-Plan.md`
- `AI-ML-Complete-Next-Steps.md`
- `LEGACY_ELIMINATION_SUCCESS.md`
- `LEGACY_MIGRATION_FINAL_PLAN.md`
- `Migration-History-Complete.md`

## Executive summary

This repository's `01_ReferenceLibrary` holds the unified learning hub and a legacy migration archive. Over time multiple planning and migration documents were created; this consolidated overview extracts the actionable elements and key dates, presents a single migration status snapshot, and outlines the next 90-day priorities.

High-level outcomes:

- Legacy migration: archive content centralized under `97_Legacy-Migration-Archive/` and migration steps completed where noted.
- Format-conversion: plan to enforce ~200-line module chunks with strict quality gates, linting, and link checks.
- AI/ML track: next-steps prioritized with learning paths, content gaps flagged and scheduled.

## Migration status (snapshot)

- Migration strategy: phased migration with validation (readability, lint, links, zero-copy policy).
- Current state: core Reference Library established; legacy content moved into `97_Legacy-Migration-Archive/` with migration artifacts retained for audit.
- Success criteria: single root `README.md`, working doc-quality CI (`.github/workflows/docs-quality.yml`), and `05_Todos/` used for planning.

## 200-line format conversion (summary)

- Goal: split long pages into focused ~200-line modules (27-minute learning segments) with STSA metadata.
- Quality gates: markdownlint rules, Lychee link checks, zero-copy audit, and multi-part segmentation enforcement.
- Implementation notes: create new modules alongside originals, update cross-links, and use a PR template for format compliance.

## AI/ML next steps (summary)

- Prioritize AI Agents and Model-guidance pages, add unique examples, and ensure zero-copy policy is applied to all migrated content.
- Immediate milestones: complete AI fundamentals modules, finalize Model Variants consolidation, and publish a track README with learning objectives.

## Key recommendations (next 90 days)

1. Triage outstanding TODOs from `tools/todo-report.csv` into issues with priority labels.
2. Run `tools/docs-lint.ps1 -Fix` and `tools/docs-links.ps1` (link-check in Docker) and address high-impact failures.
3. Incrementally split the largest ReferenceLibrary pages into 200-line modules, starting with high-traffic topics.
4. Keep legacy material read-only in `97_Legacy-Migration-Archive/` and only migrate content that meets quality gates.

## Cross-reference map

- Migration artifacts: `01_ReferenceLibrary/97_Legacy-Migration-Archive/`
- TODOs export: `tools/todo-report.csv`
- Lint script: `tools/docs-lint.ps1`
- Link-check script: `tools/docs-links.ps1`

---

If you want, I can (a) draft issue titles/bodies for the highest-impact TODOs, (b) split one large page into a 200-line module as an example, or (c) run the linter and link-check if Node/Docker are available. Which should I do next?
