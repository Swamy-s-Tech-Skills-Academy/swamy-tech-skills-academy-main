# 🛠️ STSA Tools Collection

Collection of PowerShell tools for daily learning system management and quality assurance.

---

## 📋 Available Tools

### Daily Verification Tools

#### 1️⃣ **verify-domain.ps1**

Quick health check for any learning domain.

**Usage:**

```powershell
# Interactive mode - select domain from menu
.\verify-domain.ps1

# Direct domain check
.\verify-domain.ps1 -Domain "01_OOP-Fundamentals"
```

**Features:**

- ✅ File count validation
- ✅ Line limit compliance (300 lines max)
- ✅ Encoding issue detection
- ✅ README.md presence check
- ✅ Part file structure verification

#### 2️⃣ **file-analysis.ps1**

Detailed analysis of files in any folder path.

**Usage:**

```powershell
# Analyze specific domain
.\file-analysis.ps1 -Path "01_ReferenceLibrary\01_Development\01_software-design-principles\01_OOP-Fundamentals"

# Include content preview
.\file-analysis.ps1 -Path "path\to\folder" -IncludeContent

# Custom line limit and filter
.\file-analysis.ps1 -Path "path\to\folder" -LineLimit 200 -Filter "*.txt"
```

**Features:**

- 📊 Comprehensive file statistics
- 🔍 Issue detection (encoding, line limits, missing language tags)
- 📈 Summary analytics
- 👀 Content preview option
- 💡 Quality recommendations

#### 3️⃣ **daily-progress.ps1**

Track learning progress across all domains and individual domain analysis.

**Usage:**

```powershell
# Overview of all domains
.\daily-progress.ps1 -AllDomains

# Specific domain analysis
.\daily-progress.ps1 -Domain "01_OOP-Fundamentals"

# Detailed domain review
.\daily-progress.ps1 -Domain "01_OOP-Fundamentals" -ShowDetails
```

**Features:**

- 📈 Progress tracking across domains
- 📊 Completion statistics
- 🎯 Domain-specific analysis
- 📝 Content feature detection
- 💡 Structured recommendations

### Existing Quality Tools

#### 4️⃣ **docs-lint.ps1**

Markdown linting for style compliance.

```powershell
.\docs-lint.ps1
```

#### 5️⃣ **docs-links.ps1**

Link validation across documentation.

```powershell
.\docs-links.ps1
```

#### 6️⃣ **pre-commit.ps1**

Complete validation suite for pre-commit checks.

```powershell
.\pre-commit.ps1
```

---

## 📋 Daily Workflow Examples

### 🌅 Morning Routine

```powershell
# 1. Get overview of all learning progress
.\daily-progress.ps1 -AllDomains

# 2. Select today's domain for focused work (interactive)
.\verify-domain.ps1
```

### 🎯 During Work Session

```powershell
# 1. Analyze files before editing
.\file-analysis.ps1 -Path "current\domain\path"

# 2. (Create/Edit content)

# 3. Verify changes meet quality standards
.\verify-domain.ps1 -Domain "current-domain"
```

### 🌙 End of Day Validation

```powershell
# 1. Check markdown formatting
.\docs-lint.ps1

# 2. Validate all links
.\docs-links.ps1

# 3. Final validation before commit
.\pre-commit.ps1
```

---

## ⚡ Quick Commands

### Most Common Daily Commands

```powershell
# Check OOP Fundamentals domain
.\verify-domain.ps1 -Domain "01_OOP-Fundamentals"

# Get full progress overview
.\daily-progress.ps1 -AllDomains

# Interactive domain selection
.\verify-domain.ps1

# Analyze specific folder
.\file-analysis.ps1 -Path "01_ReferenceLibrary\01_Development\01_software-design-principles\01_OOP-Fundamentals"
```

---

## 🎯 Success Metrics

The tools help ensure all content meets STSA quality standards:

- ✅ **Files under 300 lines** - Optimal 30-minute learning segments
- ✅ **No encoding issues** - Clean UTF-8, no 🔧 characters
- ✅ **Proper markdown formatting** - Professional documentation
- ✅ **README.md in each domain** - Clear navigation and context
- ✅ **Part file structure** - Structured learning progression (01A_, 01B_, etc.)
- ✅ **Cross-references working** - Integrated learning system
- ✅ **Mermaid diagrams validated** - Visual learning aids function properly

---

## 💡 Pro Tips

1. **Add to PATH**: Make tools globally accessible by adding the `tools` directory to your PowerShell PATH
2. **Daily Habit**: Start each day with `.\daily-progress.ps1 -AllDomains` for strategic overview
3. **Before Commit**: Always run `.\pre-commit.ps1` before committing changes
4. **Interactive Mode**: Use `.\verify-domain.ps1` without parameters for guided domain selection
5. **Batch Analysis**: Use `.\file-analysis.ps1` to understand content structure before major refactoring

---

## 🔧 Tool Development Notes

All tools follow STSA development principles:

- **PowerShell native** - Works on Windows environments
- **Repository-aware** - Automatically detects repository structure
- **Color-coded output** - Easy visual parsing of results
- **Flexible parameters** - Adaptable to different use cases
- **Error handling** - Graceful failure modes with helpful messages
- **Educational focus** - Aligned with 30-minute learning segment methodology

---

*Tools collection supporting the Lead Architect learning journey through systematic, quality-assured content mastery.*

---

## Appendix A — TODO Scan Report (auto-generated snapshot)

Date: 2025-09-17

### Summary

- Total matches found (grep snapshot): 84 (representative sample)
- High-priority areas:
  - `01_ReferenceLibrary/97_Legacy-Migration-Archive/Data-Structures-Algorithms-Legacy/` — many `TODO` items in templates and lesson plans
  - `01_ReferenceLibrary/01_Development/17_Git-Version-Control/` — four files with `## TODO` headings
  - Migration planning files with 'Migration TODO:' markers

### Suggested next steps

1. Run `tools/extract-todos.ps1` to produce an up-to-date CSV of TODO locations.
2. Triage TODOs into issues or move high-priority items into `05_Todos/` for scheduled work.
3. Implement low-effort fixes (stubs, placeholders) for `## TODO` headings to improve reader experience.

### Top example files with TODOs

- `01_ReferenceLibrary/97_Legacy-Migration-Archive/Data-Structures-Algorithms-Legacy/_shared/CodeTemplates/CodeExampleTemplates.md`
- `01_ReferenceLibrary/97_Legacy-Migration-Archive/Data-Structures-Algorithms-Legacy/WeeklyLessons/Week01-BigO-LessonPlan.md`
- `01_ReferenceLibrary/01_Development/17_Git-Version-Control/04_Undo-Strategies.md`
- `01_ReferenceLibrary/01_Development/17_Git-Version-Control/05_Branching-Patterns.md`

Notes:

- This snapshot was created during a repository scan. Use `tools/extract-todos.ps1` for a fresh run.
