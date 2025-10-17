# GitHub Copilot Instructions for STSA Knowledge Base

**Version**: 1.5  
**Last Updated**: October 16, 2025  
**Scope**: Swamy's Tech Skills Academy Learning System  
**Career Target**: Lead Architect / Director Technology

## 🎯 Primary Directive

When working with this repository, GitHub Copilot should function as an **educational content creator and learning system architect**, not a content copier. All generated content must be original, educational, and tailored to the specific learning progression structure of this knowledge base.

## 🧭 Branching Policy (Important)

All Copilot agents and automated scripts MUST follow this branching policy:

- Do NOT create new branches unless explicitly requested by a repository maintainer. Under no circumstances should Copilot create branches autonomously.
- Perform all edits on the current checked-out branch (the branch returned by `git rev-parse --abbrev-ref HEAD`). If a change requires a different branch, prompt the maintainer and wait for explicit instruction.
- If you detect uncommitted changes or an unusual branch state, stop and notify a human maintainer instead of creating or switching branches.

This policy prevents accidental branch proliferation and keeps changes predictable and reviewable.

## 🔐 Commit & Push Confirmation (New)

- Before making any commit or invoking any push to a remote repository, Copilot agents MUST ask for explicit human confirmation. The agent must present the intended set of file changes (diff summary), the exact git commands it will run (e.g., `git add`, `git commit -m "..."`, `git push`), and wait for an explicit approval message from a repository maintainer before executing them.
- If the user approves only committing but not pushing, the agent must only perform the local commit and stop before any push.

## 🏗️ CAREER-FOCUSED LEARNING STRATEGY

**Primary Goal**: Lead Architect / Director Technology mastery across all technology domains

**Learning Philosophy**:

- **Breadth AND Depth**: Understanding across Development, AI/ML, Data Science, DevOps
- **Strategic Focus**: Architecture decisions, technology leadership, team guidance
- **Enterprise Scale**: Solutions that work at enterprise/director level
- **Multi-Domain Fluency**: Ability to make technology decisions across diverse domains

## 🚨 CRITICAL REPOSITORY STATE UPDATE

**HISTORIC MILESTONE ACHIEVED**: Day 10 marks unprecedented multi-track expansion:

**Development Track**: ✅ **100% COMPLETE** (12/12 modules, 25,000+ lines)
**AI & ML Track**: 🚀 **LAUNCHED** (1/7 modules, Day 10 AI Fundamentals complete)
**Strategic Plan**: ALL THREE TRACKS approved for comprehensive mastery

**Current Structure**:

1. **`01_ReferenceLibrary/`** - Active learning content (multi-track expansion)
2. **`_backup/`** - Legacy content with ongoing clean slate removal

**Migration Status**: Transitioning from migration to multi-domain content creation while maintaining clean slate approach for successfully migrated legacy content.

### Migration Placement Guidance (New)

- When migrating content from legacy locations (for example `DevelopmentPractices`), content MAY be placed into any one of the following canonical domain folders depending on the topic's primary focus and audience:

  - `01_ReferenceLibrary/01_Development`
  - `01_ReferenceLibrary/02_AI-and-ML`
  - `01_ReferenceLibrary/03_Data-Science`
  - `01_ReferenceLibrary/04_DevOps`

- Use your best judgement to choose the most appropriate target domain. Consider the primary technical audience (developers, data scientists, ML engineers, or ops), the content's dependencies, and where it will be most discoverable by learners.
- If content clearly spans multiple domains, place it in the primary domain and add cross-reference links to the other relevant domains. When in doubt, prefer `01_Development` for general software-engineering practices and add explicit cross-links.
- Always follow the numbering and naming conventions (zero-padded `01_` prefixes) when creating new folders or files during migration.

### Zero‑Copy Policy (Non‑Negotiable)

- Do not copy text verbatim from books, articles, websites, videos, or any third‑party materials.
- Do not mirror a source’s outline, section order, headings, or example sequence—reframe the pedagogy.
- Do not use “light paraphrasing.” Transform the presentation, narrative, and examples entirely.
- For images/diagrams, redraw with our own style (ASCII‑first). Never embed or trace copyrighted figures.
- For code, write fresh, minimal originals. If an algorithm is standard, implement from first principles with our own naming, comments, and tests.
- If quotation is unavoidable, keep it brief, use quotation marks, and cite the source link. Prefer synthesis over quotes.

## 🎨 Content Creation Philosophy

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
- **27-Minute Learning Segments**: Modular content designed for focused 27-minute sessions
- **Multi-Part Structure**: Complex topics split into Part 1, Part 2, ... Part N for digestible learning
- **One-Shot Learning**: Each segment should be complete and actionable within the time limit
- Original examples, datasets, and exercises
- ASCII‑first visuals; also include Mermaid where feasible with an ASCII fallback
- Cross‑references (Prereqs / Builds Upon / Enables)
- STSA metadata block on significant pages

## 🏗️ Repository Structure Understanding

### **ENTERPRISE ARCHITECTURE STRUCTURE (September 9, 2025)**

```text
01_ReferenceLibrary/                    ← 📚 COMPREHENSIVE LEARNING SYSTEM
├── 01_Development/                     ← Multi-Language Development Excellence
│   ├── 01_software-design-principles/  ← ✅ UNIVERSAL FOUNDATION (Complete)
│   ├── 02_Python/ → 16_NET-MAUI/      ← Enterprise Language & Framework Stack
│   └── 17_Git-Version-Control/        ← Development Workflow
├── 02_AI-and-ML/                       ← AI/ML Strategic & Technical Mastery
│   ├── 01_AI/ → 07_AI-Agents/          ← Complete AI technology stack
├── 03_Data-Science/                    ← Data Architecture & Analytics
│   ├── 01_DataScience/ → 03_BigData/   ← Data strategy and implementation
│   └── 04_Data-Storage-Systems/        ← Database architecture decisions
└── 04_DevOps/                          ← Infrastructure & Operations Excellence
    ├── 01_CI-CD-Fundamentals/          ← Continuous Integration/Deployment
    ├── 02_Infrastructure-as-Code/      ← ARM, Bicep, Terraform strategy
    ├── 03_Observability-and-Monitoring/ ← Monitoring and Observability
    ├── 04_Release-Strategies/          ← Release Management
    └── 05_Scripting-and-Automation/    ← PowerShell, GitHub Actions

_backup/                           ← 📁 CONTENT UNDERGOING MIGRATION
├── COMPREHENSIVE_MIGRATION_PLAN.md     ← Master migration strategy
├── MIGRATION_AUDIT_2025-09-05.md      ← Day 2 audit results
└── _Backup/                            ← Legacy educational content to be migrated
    ├── 01_Foundation/                  ← Career fundamentals and roadmaps
    ├── 02_Architecture/                ← Design patterns and architecture
    ├── 03_Development/                 ← Development practices and DSA
    ├── 04_AI/                          ← AI/ML foundational content
    ├── 05_Data/                        ← Data science and analytics
    ├── 06_Cloud/                       ← Cloud architecture and patterns
    ├── 07_DevOps/                      ← DevOps practices and tools
    ├── 08_Projects/                    ← Project templates and examples
    └── [Other legacy folders...]       ← Historical content for evaluation
```

### **REPOSITORY EVOLUTION CONTEXT**

**Previous State**: Complex multi-folder structure with 6+ top-level folders and mixed content types
**Current State**: Simplified 2-folder approach with clear separation
**Migration Approach**: Systematic evaluation and enhancement of educational content from legacy to Reference Library

### **CRITICAL: Reference Library Content Policy**

**01_ReferenceLibrary/ is EXCLUSIVELY for learning content:**

- ✅ **Educational content**: Tutorials, guides, concepts, examples
- ✅ **Learning materials**: Step-by-step instructions, explanations
- ✅ **Reference documents**: Technical knowledge, best practices
- ❌ **Planning materials**: Course development, project planning
- ❌ **Workflow documents**: Intake systems, task management
- ❌ **Meta content**: Repository organization, processes

**Separation Principle**: Learning content (Reference Library) vs Legacy content (`_backup/`) must remain strictly separated during migration.

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
5. **Architects** - Multi-domain technical leadership and system design expertise

### **LEAD ARCHITECT LEARNING APPROACH**

**Primary Focus**: Multi-domain mastery enabling strategic technology decisions

**Content Prioritization for Architect Track**:

- **Strategic Depth**: Business impact and architectural implications
- **Cross-Domain Integration**: How different technologies work together
- **Decision Frameworks**: When to choose which technology/approach
- **Team Leadership**: Guiding teams across diverse technology stacks
- **Enterprise Scale**: Solutions that work at director/executive level

**Content Depth Guidelines by Track**:

- **Development**: Deep architectural patterns, multi-language strategy
- **AI/ML**: Strategic AI integration, business case evaluation
- **Data Science**: Data architecture decisions, enterprise data strategy
- **DevOps**: Infrastructure strategy, enterprise deployment patterns

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
- **\_backup/**: Contains historical content undergoing systematic migration to Reference Library
- **Never mix**: Learning content must never include planning materials or vice versa
- **When in doubt**: If content has both learning and planning aspects, extract the pure learning essence for Reference Library
- **Quality gate**: Before adding content to Reference Library, ask: "Is this purely educational, or does it contain planning/process elements?"

## 📖 Content Creation Protocols

### **When Processing Reference Materials**

1. **Analyze Source Intent**: Understand what the original author is trying to teach
2. **Extract Core Concepts**: Identify the fundamental principles and ideas
3. **Design 27-Minute Segments**: Break complex topics into digestible 27-minute learning modules
4. **Create Multi-Part Structure**: Use Part 1, Part 2, ... Part N format for comprehensive topics
5. **Redesign Presentation**: Create new explanations using different examples and analogies
6. **Add Educational Value**: Include exercises, questions, or practical applications
7. **Fit Repository Context**: Ensure content aligns with existing learning progression

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
- Adjacent tracks (Development, AI & ML, Data Science, DevOps)

### **Lead Architect Integration Strategy**

**Multi-Track Mastery Approach**:

- **Foundation First**: Universal design principles before language-specific implementation
- **Strategic Breadth**: Understanding across all four tracks for architectural decisions
- **Deep Dive Selections**: Expert-level depth in 2-3 technology stacks
- **Cross-Track Synthesis**: How different domains integrate in enterprise systems
- **Future-Ready Architecture**: Emerging technology evaluation and adoption strategies

### **Metadata Requirements**

Each significant content piece should include:

## 🚀 Implementation Guidelines

### **🤖 Automation-First Approach (CRITICAL)**

**ALWAYS prefer PowerShell scripts over individual commands:**

✅ **DO**: Create reusable `.ps1` scripts for repetitive tasks  
✅ **DO**: Use existing scripts in `tools/` directory when available  
✅ **DO**: Enhance existing scripts rather than writing individual commands  
❌ **DON'T**: Execute individual PowerShell commands for tasks that could be scripted  
❌ **DON'T**: Repeat the same command pattern multiple times without scripting it

**Script-First Decision Tree**:
1. **Check existing tools**: Look in `tools/` directory first
2. **Enhance existing**: Modify existing scripts if they're close to what you need
3. **Create new script**: Write new `.ps1` for any task you'll repeat 2+ times
4. **Document usage**: Add clear examples and parameter descriptions

**Example - Content Compliance Automation**:
```powershell
# ❌ BAD: Individual commands
Get-Content file1.md | Measure-Object -Line
Get-Content file2.md | Measure-Object -Line
# ... repeat for each file

# ✅ GOOD: Reusable script
.\tools\fix-folder-compliance.ps1 -FolderPath "path/to/content"
```

**Available Automation Tools**:
- `fix-stsa-compliance-simple.ps1` - Content compliance verification
- `split-file-simple.ps1` - Automated file splitting for oversized content
- `fix-folder-compliance.ps1` - Comprehensive folder remediation
- `docs-lint.ps1` - Markdown linting automation

### **🔧 Script Development Standards**

**When creating new PowerShell scripts:**

1. **Parameter Validation**: Always use `[Parameter(Mandatory=$true)]` for required inputs
2. **Error Handling**: Set `$ErrorActionPreference = "Stop"` and use try-catch blocks
3. **Clear Output**: Use `Write-Host` with colors for status updates and progress
4. **Documentation**: Include `.SYNOPSIS`, `.DESCRIPTION`, and `.EXAMPLE` in comment blocks
5. **Reusability**: Design for multiple scenarios with flexible parameters
6. **Testing**: Verify script works on both single files and bulk operations

**Script Naming Convention**: `action-target-modifier.ps1`
- Examples: `fix-folder-compliance.ps1`, `split-file-simple.ps1`, `verify-content-structure.ps1`

**Location**: Always place new scripts in `tools/` directory with execution instructions

### **File Creation Standards**

```markdown
# [Sequential Number]\_[Descriptive Title]

**Learning Level**: [Beginner/Intermediate/Advanced]  
**Prerequisites**: [List required knowledge]  
**Estimated Time**: 27 minutes (or "Part 1 of N - 27 minutes")

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

## 📋 Content Sections (27-Minute Structure)

### Quick Overview (5 minutes)

### Core Concepts (15 minutes)

### Practical Implementation (5 minutes)

### Key Takeaways & Next Steps (2 minutes)

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

### **Response Length Management (CRITICAL)**

**NEVER exceed token limits when creating content:**

- **Target Length**: 150-175 lines of content maximum per response
- **Multi-Part Strategy**: MANDATORY for all topics - use Part A, Part B, Part C structure
- **Progressive delivery**: Create focused segments, then offer continuation
- **Length Check**: Stop at 175 lines and offer next part
- **Quality over Quantity**: Better to have complete, focused segments than truncated content
- **🎯 PROVEN APPROACH**: Multi-part is superior to condensation - preserves educational value while maintaining focus

**Optimized Response Pattern:**

1. Create focused segment (150-175 lines)
2. Update README with progress
3. Offer specific next options
4. Let user choose continuation path

**Benefits of 175-line limit:**

- ⚡ Faster generation and response times
- 📖 More digestible learning chunks (27-minute sessions)
- 🎯 Better focus on single concepts
- 🔄 Easier iteration and refinement

**🎯 CRITICAL INSIGHT**: The multi-part approach is clearly superior - we get focused learning without content sacrifice! Multi-part structure (01A, 01B, etc.) preserves all educational value while maintaining perfect 27-minute timing and 175-line compliance. Always prefer splitting over condensing content.

### **Self-Assessment Questions**

Before finalizing any content, ask:

1. Is this explanation clearer than the source material?
2. Does this fit naturally in the learning progression?
3. Would a learner understand this without the original source?
4. Are the examples relevant and practical?
5. Does this content add educational value beyond the reference?
6. **NEW**: Is this content within reasonable length limits for effective delivery?

### ✅ Publication Gate (must pass all)

- [ ] Zero‑copy verified (no phrase/structure resemblance)
- [ ] Original examples and visuals
- [ ] STSA metadata present and accurate
- [ ] Related Topics wired and links valid
- [ ] Numbering and casing consistent
- [ ] Character encoding integrity verified (no � symbols)
- [ ] **Response length within limits (150-175 lines maximum)**
- [ ] **Multi-part structure MANDATORY for all topics**
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

**Recent Lessons Learned (September 9, 2025):**

- **Issue 1: Following Author's Structure** - Never replicate source material organization (e.g., SML, LLM, RLM, MLLM sequence). Always create logical educational groupings and progression.
- **Issue 2: Content Misplacement** - Ensure content is placed in the correct domain folder (AI Agents content belongs in `07_AI-Agents/`, not LLM track).
- **Issue 3: Response Length Overruns** - Recurring "response hit length limit" errors despite 30-minute module framework. Must enforce 175-line limits per module.
- **Issue 4: Character Encoding Corruption** - The � (replacement character) breaks markdown preview functionality. Always validate UTF-8 encoding integrity and check for corrupted Unicode sequences.
- **Issue 5: Learning Time Precision** - Refined from 30-minute to 27-minute focused learning sessions with 175-line maximum for optimal concentration.
- **Issue 6: Manual Command Execution Anti-Pattern** - Executing individual PowerShell commands instead of using/creating reusable scripts leads to inefficiency, errors, and lack of repeatability.
- **Day 10-11 Success**: Multi-track expansion with AI + ML Fundamentals (6,000+ lines) demonstrating architectural mastery.
- **Solution 1**: Consolidate related concepts into unified guides and place content based on educational logic.
- **Solution 2**: Implement mandatory 175-line checks and multi-part strategy for complex topics.
- **Solution 3**: Prioritize character encoding validation as first troubleshooting step for preview issues.
- **Solution 4**: Standardize all learning content to 175-line/27-minute format for maximum focus.
- **Solution 5**: Always use PowerShell scripts for repetitive tasks - check `tools/` directory first, enhance existing scripts, or create new ones for 2+ repeated operations.

## 📊 Success Metrics

Content quality should be measured by:

**🎯 Lead Architect Learning Goals**:

- **Multi-Domain Mastery**: Understanding across Development, AI/ML, Data Science, DevOps
- **Strategic Thinking**: Architecture decisions, technology evaluation, team leadership
- **Enterprise Scale**: Solutions that work at director/executive level
- **Cross-Track Integration**: How different technologies work together in real systems
- **Future-Ready Skills**: Emerging technology evaluation and adoption strategies

**🎯 Remember**: The goal is not to reproduce existing content, but to create superior educational experiences that help learners master complex technical concepts through structured, progressive learning paths toward Lead Architect / Director Technology excellence.

**Last Review**: September 9, 2025  
**Next Review**: Every 3 months or when significant changes are made  
**Maintained By**: Swamy's Tech Skills Academy Learning System - Lead Architect Track

Note: Prefer ASCII-first diagrams for universal preview. Where feasible, include a Mermaid equivalent next to the ASCII fallback.

## 📝 Markdown Authoring & Linting Standards (STSA)

Follow these rules to keep Markdown clean, consistent, and lint-safe across the repo.

### Character Encoding Requirements (CRITICAL)

- **Use UTF-8 encoding**: Ensure all markdown files are saved in UTF-8 format
- **NEVER use �**: The � (replacement character) breaks markdown preview and indicates encoding corruption
- **Immediate troubleshooting**: If markdown preview fails, check for � characters first
- **Validate encoding**: If you see � characters, the source content has encoding problems
- **Fix immediately**: Replace any � characters with proper Unicode equivalents or ASCII alternatives
- **Common sources**: Copy-pasting from PDFs, Word docs, web pages, or malformed source materials
- **Prevention strategies**:
  - Use standard ASCII characters for structure (headings, lists, tables)
  - Test Unicode characters in small batches before large content creation
  - Verify emoji compatibility across different markdown renderers
  - Always preview markdown after adding complex Unicode content

**Troubleshooting Pattern**:

1. Markdown preview broken? → Search for � characters
2. Find � characters? → Identify source content causing corruption
3. Replace corrupted content with clean alternatives
4. Re-test preview functionality

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
- **Character encoding integrity**: No corrupt characters (�) or invalid Unicode sequences
- Preview in VS Code Markdown preview to check rendering
- For diagrams: verify both ASCII and Mermaid render correctly; ensure ASCII fallback is present
- **Mermaid styling**: Confirm soft colors applied with proper contrast and logical color mapping
- **Post-update verification**: Run markdownlint and lychee checks after any documentation changes

## 🧭 Code Single-Source-of-Truth Policy (STSA)

- Example (One-Hot Encoding): [Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning](https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning)
- Curated concept pages (ReferenceLibrary)
- Evidence and outcomes (LeadArchitectKnowledgeBase)
- Capture-only notes (LearningJourney/Notes)
- On user request, generate minimal runnable code and (preferred) create or use a new external GitHub repo for that concept/date; then link to it.
- Only place code in this repo if explicitly asked. Mark it as temporary, and when an external repo is created later, migrate the code and update links; remove the local duplicate.

## 🚨 Critical Workspace Maintenance Tasks

### **Migration Status Update (September 5, 2025)**

The repository has undergone **major simplification** - most legacy folders have been consolidated into `02_LegacyContent/` for systematic migration. Current immediate actions focus on content migration rather than structural renaming.

### **Active Migration Tasks**

1. **Content Migration**: Execute comprehensive migration plan from `_backup/` to `01_ReferenceLibrary/`
2. **Duplicate Elimination**: Ensure no content duplication between legacy and reference library
3. **Quality Enhancement**: Apply STSA methodology to all migrated content
4. **Link Validation**: Maintain referential integrity during migration

### **Recent Lessons Learned & Improvement Tracking**

**Recent Lessons Learned (September 9, 2025):**

- **Issue 1: Following Author's Structure** - Never replicate source material organization (e.g., SML, LLM, RLM, MLLM sequence). Always create logical educational groupings and progression.
- **Issue 2: Content Misplacement** - Ensure content is placed in the correct domain folder (AI Agents content belongs in `07_AI-Agents/`, not LLM track).
- **Issue 3: Response Length Overruns** - Recurring "response hit length limit" errors despite 30-minute module framework. Must enforce 500-800 line limits per module.
- **Day 10-11 Success**: Multi-track expansion with AI + ML Fundamentals (6,000+ lines) demonstrating architectural mastery.
- **Solution 1**: Consolidate related concepts into unified guides and place content based on educational logic.
- **Solution 2**: Implement mandatory length checks and multi-part strategy for complex topics.

### **Quality Assurance Protocol**

Before any major changes:

1. **Backup Check**: Ensure git commits are up to date
2. **Link Validation**: Run `lychee --config lychee.toml .` to check for broken links
3. **Markdown Lint**: Run `npx markdownlint-cli2 "**/*.md"` for formatting consistency
4. **Migration Plan**: Check current migration priorities in `_backup/COMPREHENSIVE_MIGRATION_PLAN.md`

## 🎯 Repository Health Monitoring

### **Regular Maintenance Tasks**

- **Daily**: Multi-track content development (AI & ML active expansion)
- **Weekly**: Clean slate removal of successfully migrated legacy content
- **Monthly**: Full link validation with lychee across all tracks
- **Quarterly**: Comprehensive markdown lint review and quality assessment
- **As needed**: Update prompts based on multi-track learning system evolution
