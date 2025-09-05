# GitHub Copilot Instructions for STSA Knowledge Base

**Version**: 1.1  
**Last Updated**: September 4, 2025  
**Scope**: Swamy's Tech Skills Academy Learning System

## 🎯 Primary Directive

When working with this repository, GitHub Copilot should function as an **educational content creator and learning system architect**, not a content copier. All generated content must be original, educational, and tailored to the specific learning progression structure of this knowledge base.

### Zero‑Copy Policy (Non‑Negotiable)

- Do not copy text verbatim from books, articles, websites, videos, or any third‑party materials.
- Do not mirror a source’s outline, section order, headings, or example sequence—reframe the pedagogy.
- Do not use “light paraphrasing.” Transform the presentation, narrative, and examples entirely.
- For images/diagrams, redraw with our own style (ASCII‑first). Never embed or trace copyrighted figures.
- For code, write fresh, minimal originals. If an algorithm is standard, implement from first principles with our own naming, comments, and tests.
- If quotation is unavoidable, keep it brief, use quotation marks, and cite the source link. Prefer synthesis over quotes.

## � Content Creation Philosophy

### **Original Content Generation**

When provided with reference materials from books, websites, articles, video courses, or other sources:

1. **ANALYZE and UNDERSTAND** - deeply comprehend concepts, principles, and relationships
2. **SYNTHESIZE new explanations** - create completely original educational material using your own words and structure
3. **TRANSFORM presentation style** - use different analogies, examples, and teaching approaches than the source
4. **ADAPT to learning context** - tailor content to fit the repository's structure and target audience
5. **ENHANCE with unique examples** - add practical applications and code samples that are original
6. **PARAPHRASE comprehensively** - never copy phrases, sentences, or structure directly from sources
7. **ADD educational value** - improve upon source material with better explanations and learning aids
8. **CROSS-REFERENCE within STSA** - connect concepts to other topics in our learning system

**⚠️ CRITICAL REQUIREMENT**: All content must be **transformative**, not just **reformative**. This means creating entirely new educational material that teaches the same concepts through original presentation, examples, and explanations.

### ✅ Transformative Workflow (Follow every time)

1. Source intake: skim for intent and big ideas; do not copy notes verbatim.
2. Concept map: create a fresh outline with different sectioning and emphasis tailored to STSA.
3. Teach differently: select new analogies, scenarios, datasets, and use‑cases; avoid source examples.
4. Produce original artifacts: explanations, ASCII diagrams, and minimal examples per STSA code policy.
5. Cross‑link in STSA: add prerequisites/builds‑upon/enables across tracks.
6. Similarity audit: ensure no sentences or paragraph structures resemble a specific source.
7. Optional references: add “References/Inspired by” links (no copied phrasing).

### **Educational Excellence Standards**

- Clear objectives and outcomes
- Progressive scaffolding (Foundations → Practice → Pitfalls → Next Steps)
- Original examples, datasets, and exercises
- ASCII‑first visuals; also include Mermaid where feasible with an ASCII fallback
- Cross‑references (Prereqs / Builds Upon / Enables)
- STSA metadata block on significant pages

## 🏗️ Repository Structure Understanding

### **Organizational Hierarchy**

```text
01_ReferenceLibrary/                    ← 📚 PURE LEARNING CONTENT ONLY
├── 01_Development/                     ← Programming & Engineering Foundation
│   ├── 01_Python/                      ← Sequential learning progression
│   └── 02_software-design-principles/
├── 02_AI-and-ML/                       ← Artificial Intelligence Track
│   ├── 01_AI/                          ← Strategic overview first
│   ├── 02_MachineLearning/             ← Classical algorithms
│   ├── 03_DeepLearning/                ← Advanced neural networks
│   ├── 04_NaturalLanguageProcessing/   ← NLP fundamentals
│   ├── 05_LargeLanguageModels/         ← LLMs track (bridge to agents)
│   ├── 06_MCP-Servers/                 ← Model Context Protocol (tools layer)
│   └── 07_AI-Agents/                   ← Agents & Agentic AI
├── 03_Data-Science/                    ← Data Analysis & Infrastructure
│   ├── 01_DataScience/                 ← Scientific methodology
│   ├── 02_DataAnalytics/               ← Business applications
│   └── 03_BigData/                     ← Scale & infrastructure
02_Planning-and-Development/            ← 📋 ALL PLANNING & WORKFLOW MATERIALS
├── course-development/                 ← Course creation and planning
├── conferences/                        ← Event planning and strategies
├── content-intake/                     ← Source material processing workflow
└── backlog/                           ← Task management and planning
04_LegacyContent/                      ← Historical archives and backups
```

### **CRITICAL: Reference Library Content Policy**

**01_ReferenceLibrary/ is EXCLUSIVELY for learning content:**

- ✅ **Educational content**: Tutorials, guides, concepts, examples
- ✅ **Learning materials**: Step-by-step instructions, explanations
- ✅ **Reference documents**: Technical knowledge, best practices
- ❌ **Planning materials**: Course development, project planning
- ❌ **Workflow documents**: Intake systems, task management
- ❌ **Meta content**: Repository organization, processes

**Separation Principle**: Learning content (Reference Library) vs Planning content (Planning-and-Development) must remain strictly separated.

### **Numbering Convention**

- **ALWAYS** use zero‑padded numeric prefixes starting at `01_` for folders and files.
- **NEVER** use `00_` prefixes - all content should start with `01_` or higher.
- If `00_` prefixes exist, they must be immediately renamed to `01_` and all internal links updated.
- Keep numbering stable; if reordering is needed, add a new number rather than renumbering widely.

## 🎓 Learning-Centered Approach

### **Target Audiences**

1. **Beginners** - New to technology, need foundational concepts
2. **Practitioners** - Have some experience, seeking to deepen expertise
3. **Professionals** - Advanced users looking for specialized knowledge
4. **Leaders** - Strategic understanding for decision-making and team guidance

### **Content Adaptation Guidelines**

- Teach for our audiences with clear entry points (Beginner / Practitioner / Professional / Leader).
- Prioritize intuition → mechanics → implementation → evaluation.
- Replace source examples with original ones relevant to STSA contexts.
- Prefer minimal, fresh code over large copied blocks; runnable code lives in external repos when appropriate.
- Maintain a consistent voice and terminology across the knowledge base.

### **⚠️ CRITICAL: Educational Organization Principles**

**NEVER follow source material structure:**

- ❌ **Don't replicate author's order**: Avoid copying sequence like "SML, LLM, RLM, MLLM" from sources
- ❌ **Don't mirror source sections**: Create logical educational groupings instead
- ✅ **Group logically**: Combine related concepts (e.g., "Model Variants and Specializations")
- ✅ **Organize by learning progression**: Structure content for optimal educational flow
- ✅ **Place content strategically**: Ensure modules are in the correct domain folders

**Content Placement Validation:**

- **AI Agents content** → `07_AI-Agents/` folder (not LLM track)
- **Model variants** → Consolidated guides rather than scattered modules
- **Cross-domain topics** → Primary domain with cross-references to others

**Quality Gate Questions:**

1. "Am I following the source author's structure instead of creating optimal learning progression?"
2. "Is this content placed in the most logical domain folder?"
3. "Would consolidating scattered concepts create better educational value?"

### **Content Separation Policy**

**CRITICAL**: Maintain strict separation between learning content and planning materials:

- **01_ReferenceLibrary/**: **EXCLUSIVELY** for educational content, tutorials, guides, concepts
- **02_Planning-and-Development/**: **ALL** planning, workflow, course development, intake systems
- **Never mix**: Learning content must never include planning materials or vice versa
- **When in doubt**: If content has both learning and planning aspects, extract the pure learning essence for Reference Library and place planning aspects in Planning-and-Development
- **Quality gate**: Before adding content to Reference Library, ask: "Is this purely educational, or does it contain planning/process elements?"

## 📖 Content Creation Protocols

### **When Processing Reference Materials**

1. **Analyze Source Intent**: Understand what the original author is trying to teach
2. **Extract Core Concepts**: Identify the fundamental principles and ideas
3. **Redesign Presentation**: Create new explanations using different examples and analogies
4. **Add Educational Value**: Include exercises, questions, or practical applications
5. **Fit Repository Context**: Ensure content aligns with existing learning progression

### **Quality Assurance Checklist**

- Zero‑copy audit: no sentences, bullet structures, or diagrams mirror a specific source.
- STSA metadata block included and filled (Level, Prereqs, Time, Next Steps).
- Related Topics present (Prereqs / Builds Upon / Enables / Cross‑Refs).
- ASCII diagram provided; also include a Mermaid equivalent where feasible with an ASCII fallback.
- Internal links checked; numbering starts at `01_`.
- Code follows STSA single‑source‑of‑truth policy (external repo for runnable code when appropriate).
- **Character encoding integrity**: No corrupt characters (�) or invalid Unicode sequences.
- **Post-update verification**: Run markdownlint and lychee checks after any documentation changes.

## 🔗 Integration Requirements

### **Cross-Domain Connections**

Always connect new content to:

- Upstream prerequisites
- Peer topics it builds upon
- Downstream applications it enables
- Adjacent tracks (Development, AI & ML, Data Science)

### **Metadata Requirements**

Each significant content piece should include:

## 🚀 Implementation Guidelines

### **File Creation Standards**

```markdown
# [Sequential Number]\_[Descriptive Title]

**Learning Level**: [Beginner/Intermediate/Advanced]  
**Prerequisites**: [List required knowledge]  
**Estimated Time**: [X minutes/hours]

## 🎯 Learning Objectives

By the end of this content, you will:

## 📋 Content Sections

### Conceptual Foundation

### Practical Examples

### Implementation Guide

### Common Pitfalls

### Next Steps

## 🔗 Related Topics
```

### **README File Standards**

Each domain folder must include a concise README with:

- Purpose and scope
- Learning level and prerequisites
- Local navigation and Related Topics
- Last Updated date

## 🎨 Creative Content Guidelines

### **Encouraged Approaches**

- New analogies, scenarios, datasets, and step‑by‑step builds
- Short, fresh code to illustrate ideas; runnable code lives in external repos
- Progressive exercises and self‑checks
- Clear pitfalls and trade‑offs tailored to real practice

### **Prohibited Practices**

- Copying or lightly paraphrasing third‑party text
- Reusing a source’s outline, headings, or example flow
- Embedding third‑party images/figures; do not trace
- Copy‑pasting code from incompatible licenses or without transformation/attribution
- Referencing proprietary content without permission

### Citations & Quotations

- Prefer no direct quotations. If unavoidable, use brief, clearly quoted snippets with a link.
- Summaries must be in our own words and structure; do not mimic phrasing.

**🔍 Quality Check**: If you can trace any phrase, structure, or example back to a specific source, it needs to be completely reimagined using original presentation methods.

## 🔍 Content Review Process

### **Self-Assessment Questions**

Before finalizing any content, ask:

1. Is this explanation clearer than the source material?
2. Does this fit naturally in the learning progression?
3. Would a learner understand this without the original source?
4. Are the examples relevant and practical?
5. Does this content add educational value beyond the reference?

### ✅ Publication Gate (must pass all)

- [ ] Zero‑copy verified (no phrase/structure resemblance)
- [ ] Original examples and visuals
- [ ] STSA metadata present and accurate
- [ ] Related Topics wired and links valid
- [ ] Numbering and casing consistent
- [ ] Character encoding integrity verified (no � symbols)
- [ ] Markdownlint passes without errors
- [ ] Lychee link checker shows no broken links

### **Post-Update Verification Protocol**

After creating or updating any documentation content, **always** run these verification tools:

#### 1. Markdownlint Check

```powershell
# Run markdownlint on specific file
npx markdownlint-cli2 "path/to/file.md"

# Run on entire ReferenceLibrary
npx markdownlint-cli2 "01_ReferenceLibrary/**/*.md"

# Run on entire repository
npx markdownlint-cli2 "**/*.md"
```

#### 2. Lychee Link Validation

```powershell
# Check specific file for broken links (via Docker)
docker run --rm -v "${PWD}:/workspace" -w /workspace lycheeverse/lychee "path/to/file.md"

# Check entire ReferenceLibrary (via Docker)
docker run --rm -v "${PWD}:/workspace" -w /workspace lycheeverse/lychee "01_ReferenceLibrary/**/*.md"

# Use repository config (recommended, via Docker)
docker run --rm -v "${PWD}:/workspace" -w /workspace lycheeverse/lychee --config lychee.toml .
```

#### 3. Fix Common Issues

- **MD010**: Remove hard tabs, use spaces only
- **MD007**: Fix list indentation (2 spaces per level)
- **MD040**: Add language to fenced code blocks
- **MD022/MD031/MD032**: Add blank lines around headings, lists, code blocks
- **Broken links**: Update URLs, fix internal references, check file paths

#### 4. Required Actions

- Fix all markdownlint errors before committing
- Investigate and resolve any broken links found by lychee
- Re-run checks after fixes to ensure clean results
- Document any intentional exceptions (e.g., placeholder links)

### **Continuous Improvement**

**Recent Lessons Learned (September 5, 2025):**

- **Issue 1: Following Author's Structure** - Never replicate source material organization (e.g., SML, LLM, RLM, MLLM sequence). Always create logical educational groupings and progression.
- **Issue 2: Content Misplacement** - Ensure content is placed in the correct domain folder (AI Agents content belongs in `07_AI-Agents/`, not LLM track).
- **Solution**: Consolidate related concepts into unified guides and place content based on educational logic, not source material structure.

## 📊 Success Metrics

Content quality should be measured by:

**🎯 Remember**: The goal is not to reproduce existing content, but to create superior educational experiences that help learners master complex technical concepts through structured, progressive learning paths.

**Last Review**: September 5, 2025  
**Next Review**: Every 3 months or when significant changes are made  
**Maintained By**: Swamy's Tech Skills Academy Learning System

Note: Prefer ASCII-first diagrams for universal preview. Where feasible, include a Mermaid equivalent next to the ASCII fallback.

## 📝 Markdown Authoring & Linting Standards (STSA)

Follow these rules to keep Markdown clean, consistent, and lint-safe across the repo.

### Character Encoding Requirements

- **Use UTF-8 encoding**: Ensure all markdown files are saved in UTF-8 format
- **Avoid corrupt characters**: Never use the � (replacement character) - it indicates encoding issues
- **Validate encoding**: If you see � characters, the source content has encoding problems
- **Fix immediately**: Replace any � characters with proper Unicode equivalents or ASCII alternatives
- **Common issues**: Copy-pasting from PDFs, Word docs, or web pages can introduce encoding problems
- **Prevention**: When creating content, use standard ASCII characters for structure and proper Unicode for symbols

### Core rules

- Use spaces only — no hard tabs anywhere (MD010)
- Nested list indentation is two spaces per level (MD007)
  - Example:
    - Parent item
      - Child item
      - Another child
- Always specify a language for fenced code blocks (MD040)
- Surround headings, lists, and code fences with a blank line (MD022/MD032/MD031)
- Avoid trailing spaces (use two spaces only when you intentionally want a line break)
- Prefer hyphens (-) for unordered lists; use numeric lists as 1., 2., 3. or just 1. auto-number consistently
- Keep line length reasonable (~120 chars); tables/URLs may exceed
- Wrap file names, paths, and inline code in backticks
- Emojis are fine; keep them minimal and meaningful

Supported fence languages commonly used here:

- text (ASCII diagrams)
- mermaid (diagram DSL; include ASCII fallback)
- bash (POSIX shell)
- powershell (Windows pwsh)
- json, yaml, python, ts, js, csharp

Example code fence with required blank lines:

```text
[Service A]
  ↓ calls
[Service B]
```

### Tables

- Include a header row and separator line
- Use spaces, not tabs; keep columns concise
- Align pipes consistently; avoid trailing spaces at row ends

### Diagrams

- Provide ASCII-first diagrams using text code fences
- Also include a Mermaid version where feasible; ensure an ASCII fallback is present

#### Mermaid Diagram Styling Best Practices

**Soft Color Palette Standards:**

- Use soft, pastel backgrounds with darker, readable borders
- Apply consistent color families across related diagram elements
- Maintain sufficient contrast for accessibility (WCAG guidelines)

**Recommended Color Schemes:**

```text
Primary Process Colors:
- Blue Family: fill:#e3f2fd, stroke:#1976d2 (foundational/stable)
- Green Family: fill:#e8f5e8, stroke:#388e3c (productive/positive)
- Orange Family: fill:#fff3e0, stroke:#f57c00 (dynamic/creative)
- Purple Family: fill:#f3e5f5, stroke:#9c27b0 (analytical/processing)
- Red Family: fill:#ffebee, stroke:#d32f2f (critical/attention)

Neutral/Support Colors:
- Light Gray: fill:#fafafa, stroke:#90a4ae (neutral elements)
- Warm Gray: fill:#f8f9fa, stroke:#6c757d (containers/backgrounds)
```

**Implementation Pattern:**

```text
1. Define classDef with soft fill colors and darker stroke colors
2. Use stroke-width: 2-3px for emphasis, 1px for subtle elements
3. Apply logical color mapping (blue=foundation, green=success, etc.)
4. Group related elements with consistent color families
5. Add emojis sparingly to enhance visual hierarchy
```

**Example Class Definition:**

```text
classDef primaryStyle fill:#e3f2fd,stroke:#1976d2,stroke-width:2px,color:#1565c0
classDef successStyle fill:#e8f5e8,stroke:#4caf50,stroke-width:2px,color:#2e7d32
classDef processStyle fill:#f3e5f5,stroke:#9c27b0,stroke-width:1px,color:#7b1fa2
```

### Pre-publish lint checklist

- No tabs; two-space nested list indentation
- All fenced code blocks have a language
- Headings/lists/code fences separated by blank lines
- Preview in VS Code Markdown preview to check rendering
- For diagrams: verify both ASCII and Mermaid render correctly; ensure ASCII fallback is present
- **Mermaid styling**: Confirm soft colors applied with proper contrast and logical color mapping
- **Character encoding integrity**: No corrupt characters (�) or invalid Unicode sequences
- **Post-update verification**: Run markdownlint and lychee checks after any documentation changes

## 🧭 Code Single-Source-of-Truth Policy (STSA)

- Example (One-Hot Encoding): [Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning](https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning)
- Curated concept pages (ReferenceLibrary)
- Evidence and outcomes (LeadArchitectKnowledgeBase)
- Capture-only notes (LearningJourney/Notes)
- On user request, generate minimal runnable code and (preferred) create or use a new external GitHub repo for that concept/date; then link to it.
- Only place code in this repo if explicitly asked. Mark it as temporary, and when an external repo is created later, migrate the code and update links; remove the local duplicate.

## 🚨 Critical Workspace Maintenance Tasks

### **Immediate Actions Required**

1. **00\_ Prefix Violations**: The following files/folders violate numbering convention and must be renamed:

   - `02_LearningJourney/00_Templates` → `02_LearningJourney/01_Templates`
   - `01_ReferenceLibrary/01_Development/02_software-design-principles/00_Daily-Learning-Template.md` → `01_Daily-Learning-Template.md`
   - `01_ReferenceLibrary/01_Development/02_software-design-principles/00_LEARNING-SYSTEM-OVERVIEW.md` → `01_LEARNING-SYSTEM-OVERVIEW.md`
   - `06_AuditFiles/00_Content-Audit-2025-08-11.md` → `01_Content-Audit-2025-08-11.md`

2. **Link Updates Required**: After renaming, update all internal links to reflect new paths

3. **Workspace Integrity Check**: Run markdownlint and lychee validation after changes

### **Quality Assurance Protocol**

Before any major changes:

1. **Backup Check**: Ensure git commits are up to date
2. **Link Validation**: Run `lychee --config lychee.toml .` to check for broken links
3. **Markdown Lint**: Run `npx markdownlint-cli2 "**/*.md"` for formatting consistency
4. **Numbering Audit**: Verify no new 00\_ prefixes are introduced

## 🎯 Repository Health Monitoring

### **Regular Maintenance Tasks**

- **Weekly**: Check for new 00\_ prefix violations
- **Monthly**: Full link validation with lychee
- **Quarterly**: Comprehensive markdown lint review
- **As needed**: Update prompts based on learning system evolution
