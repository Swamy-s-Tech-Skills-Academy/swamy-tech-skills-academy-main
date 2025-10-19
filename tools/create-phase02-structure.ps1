<#
.SYNOPSIS
Create Phase02_Frameworks structure based on Phase01_Reboot template

.DESCRIPTION
Automatically generates Phase02_Frameworks directory structure with 9 clusters,
54 content files (6 per cluster), and 10 portfolio templates following Phase01_Reboot
proven pattern. All files created with placeholder content ready for customization.

.PARAMETER BasePath
Path to the Phase02_Frameworks directory (default: 02_LeadArchitect-Learning/Phase02_Frameworks)

.EXAMPLE
.\create-phase02-structure.ps1 -BasePath "02_LeadArchitect-Learning/Phase02_Frameworks"
.\create-phase02-structure.ps1 -Verbose

.NOTES
- Creates 9 clusters × 6 files = 54 primary content files
- Creates 10 portfolio templates + README
- All files follow Phase01 naming convention (00_Week##, 01-05_Day##)
- Maintains 27-minute learning loop structure
- Follows automation-first methodology (copilot-instructions.md v1.5)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$BasePath = "02_LeadArchitect-Learning/Phase02_Frameworks"
)

$ErrorActionPreference = "Stop"

# ╔════════════════════════════════════════════════════════════╗
# ║          PHASE02 FRAMEWORKS STRUCTURE GENERATOR            ║
# ╚════════════════════════════════════════════════════════════╝

Write-Host "🏗️  Creating Phase02_Frameworks Structure" -ForegroundColor Cyan
Write-Host "📁 Base Path: $BasePath" -ForegroundColor Gray
Write-Host ""

# Cluster definitions for Phase02: Frameworks & Architectural Patterns
$clusters = @(
    @{
        Name = "Cluster01_Decision_Frameworks"
        Theme = "Architectural Decision-Making"
        Days = @(
            "Decision_Framework_Foundations",
            "Decision_Matrix_Design",
            "Trade-off_Analysis",
            "Implementation_Planning",
            "Decision_Documentation"
        )
    },
    @{
        Name = "Cluster02_Repository_Patterns"
        Theme = "Repository & Data Access Patterns"
        Days = @(
            "Repository_Pattern_Intro",
            "Unit_of_Work_Pattern",
            "Query_Optimization",
            "Caching_Strategies",
            "Pattern_Integration"
        )
    },
    @{
        Name = "Cluster03_CQRS_EventSourcing"
        Theme = "Command Query Responsibility Segregation"
        Days = @(
            "CQRS_Principles",
            "Event_Sourcing_Basics",
            "Command_Handlers",
            "Query_Models",
            "Implementation_Strategy"
        )
    },
    @{
        Name = "Cluster04_Microservices_Patterns"
        Theme = "Microservices Architecture Patterns"
        Days = @(
            "Service_Decomposition",
            "API_Gateways",
            "Service_Communication",
            "Circuit_Breakers",
            "Orchestration_Strategy"
        )
    },
    @{
        Name = "Cluster05_Resilience_Patterns"
        Theme = "Building Resilient Systems"
        Days = @(
            "Fault_Tolerance_Basics",
            "Retry_Strategies",
            "Bulkhead_Pattern",
            "Timeout_Handling",
            "Resilience_Testing"
        )
    },
    @{
        Name = "Cluster06_Security_Patterns"
        Theme = "Architectural Security Patterns"
        Days = @(
            "Authentication_Architecture",
            "Authorization_Frameworks",
            "Encryption_Strategies",
            "Secret_Management",
            "Security_Integration"
        )
    },
    @{
        Name = "Cluster07_Testing_Patterns"
        Theme = "Testing Strategy & Patterns"
        Days = @(
            "Testing_Architecture",
            "Test_Pyramid_Strategy",
            "Mock_Verification",
            "Integration_Testing",
            "Test_Automation"
        )
    },
    @{
        Name = "Cluster08_Monitoring_Observability"
        Theme = "Monitoring & Observability Patterns"
        Days = @(
            "Observability_Principles",
            "Metrics_Collection",
            "Logging_Strategy",
            "Tracing_Implementation",
            "Alerting_Framework"
        )
    },
    @{
        Name = "Cluster09_Framework_Declaration"
        Theme = "Framework Integration & Commitment"
        Days = @(
            "Framework_Assessment",
            "Integration_Planning",
            "Team_Communication",
            "Implementation_Roadmap",
            "Framework_Declaration"
        )
    }
)

# Template definitions for Phase02
$templates = @(
    @{ Name = "01_Decision-Log.md"; Description = "Decision tracking template" },
    @{ Name = "02_Architecture-Decision-Record.md"; Description = "ADR format template" },
    @{ Name = "03_Repository-Implementation.md"; Description = "Repository pattern guide" },
    @{ Name = "04_CQRS-Implementation-Canvas.md"; Description = "CQRS design canvas" },
    @{ Name = "05_Microservice-Charter.md"; Description = "Microservice specification" },
    @{ Name = "06_Resilience-Strategy.md"; Description = "Resilience planning guide" },
    @{ Name = "07_Security-Checklist.md"; Description = "Security implementation checklist" },
    @{ Name = "08_Test-Strategy-Document.md"; Description = "Testing approach guide" },
    @{ Name = "09_Observability-Dashboard.md"; Description = "Monitoring design guide" },
    @{ Name = "10_Framework-Adoption-Playbook.md"; Description = "Framework adoption guide" }
)

try {
    # ═══════════════════════════════════════════════════════════
    # STEP 1: Create base directory
    # ═══════════════════════════════════════════════════════════
    
    if (-not (Test-Path $BasePath)) {
        New-Item -ItemType Directory -Path $BasePath -Force | Out-Null
        Write-Host "✓ Created base directory" -ForegroundColor Green
    } else {
        Write-Host "ℹ Base directory already exists" -ForegroundColor Yellow
    }
    
    # ═══════════════════════════════════════════════════════════
    # STEP 2: Create templates folder
    # ═══════════════════════════════════════════════════════════
    
    $templatesPath = Join-Path $BasePath "01_Templates"
    New-Item -ItemType Directory -Path $templatesPath -Force | Out-Null
    Write-Host "✓ Created templates directory" -ForegroundColor Green
    
    # Create template files
    foreach ($template in $templates) {
        $templateFile = Join-Path $templatesPath $template.Name
        $content = @"
# $($template.Name.Replace('.md', '').Replace('-', ' '))

**Purpose**: $($template.Description)  
**Learning Level**: Intermediate/Advanced  
**Estimated Time**: 27 minutes

## Overview

This template supports framework implementation and architectural decision-making for Phase02_Frameworks.

## Key Sections

### Definition
- Clear definition of the pattern or framework
- When to use
- When NOT to use

### Implementation Steps
- Step-by-step implementation guide
- Code examples
- Configuration details

### Integration Points
- How this integrates with other patterns
- Prerequisites
- Dependencies

### Success Criteria
- Measurable outcomes
- Validation steps
- Testing approach

## References

Related clusters and patterns that complement this framework.

## Next Steps

Integration with Phase02 learning progression.

---

**Template**: Phase02_Frameworks  
**Created**: October 19, 2025  
**Status**: Ready for customization
"@
        
        Set-Content -Path $templateFile -Value $content -Encoding UTF8
    }
    
    Write-Host "✓ Created 10 portfolio templates" -ForegroundColor Green
    
    # Create templates README
    $templatesReadme = @"
# Phase02_Frameworks: Portfolio Templates

This folder contains 10 reusable templates for Phase02_Frameworks learning clusters.

## Template Inventory

| # | Template | Purpose |
|---|----------|---------|
| 1 | Decision-Log.md | Track architectural decisions over time |
| 2 | Architecture-Decision-Record.md | Formal ADR documentation |
| 3 | Repository-Implementation.md | Repository pattern implementation guide |
| 4 | CQRS-Implementation-Canvas.md | CQRS pattern design and planning |
| 5 | Microservice-Charter.md | Microservice boundary definition |
| 6 | Resilience-Strategy.md | System resilience planning |
| 7 | Security-Checklist.md | Security architecture validation |
| 8 | Test-Strategy-Document.md | Comprehensive testing approach |
| 9 | Observability-Dashboard.md | Monitoring and observability design |
| 10 | Framework-Adoption-Playbook.md | Framework adoption roadmap |

## Usage

Each template is designed for a specific cluster in Phase02_Frameworks:

- **Cluster01**: Templates 1-2 (Decision-making)
- **Cluster02**: Template 3 (Repository patterns)
- **Cluster03**: Template 4 (CQRS)
- **Cluster04**: Template 5 (Microservices)
- **Cluster05**: Template 6 (Resilience)
- **Cluster06**: Template 7 (Security)
- **Cluster07**: Template 8 (Testing)
- **Cluster08**: Template 9 (Observability)
- **Cluster09**: Template 10 (Framework adoption)

---

**Phase02_Frameworks Templates**  
**Last Updated**: October 19, 2025
"@
    
    Set-Content -Path (Join-Path $templatesPath "README.md") -Value $templatesReadme -Encoding UTF8
    Write-Host "✓ Created templates README" -ForegroundColor Green
    
    # ═══════════════════════════════════════════════════════════
    # STEP 3: Create clusters with content files
    # ═══════════════════════════════════════════════════════════
    
    $fileCount = 0
    
    foreach ($cluster in $clusters) {
        $clusterPath = Join-Path $BasePath $cluster.Name
        New-Item -ItemType Directory -Path $clusterPath -Force | Out-Null
        
        # Create week overview file (00_Week##)
        $weekNum = $clusters.IndexOf($cluster) + 1
        $weekFile = Join-Path $clusterPath "00_Week$($weekNum.ToString('00'))_$($cluster.Theme.Replace(' ', '_')).md"
        
        $weekContent = @"
# Week $weekNum`: $($cluster.Theme)

**Learning Level**: Advanced (Lead Architect)  
**Prerequisites**: Phase01_Reboot completion  
**Estimated Time**: 4.5 hours (10 × 27-minute loops)

## 🎯 Learning Objectives

By the end of this week, you will:

1. Understand the core principles of $($cluster.Theme.ToLower())
2. Apply framework patterns to architectural decisions
3. Integrate this framework into your leadership toolkit

## 📋 Week Structure (10 Loops)

| Loop | Duration | Focus | Output |
|------|----------|-------|--------|
| 1 | 27 min | Foundations | Core concept notes |
| 2 | 27 min | Principles | Pattern analysis |
| 3 | 27 min | Implementation | Design decisions |
| 4 | 27 min | Integration | System mapping |
| 5 | 27 min | Examples | Real-world cases |
| 6 | 27 min | Validation | Checklist review |
| 7 | 27 min | Architecture | Architectural sketch |
| 8 | 27 min | Practice | Implementation plan |
| 9 | 27 min | Feedback | Team review |
| 10 | 27 min | Synthesis | Weekly summary |

## 📅 Daily Flow (5 Days)

| Day | Theme | Loops | Intent |
|-----|-------|-------|--------|
| Day 1 | Understanding | 2 | Build foundational knowledge |
| Day 2 | Application | 2 | Apply to real scenarios |
| Day 3 | Analysis | 2 | Deep dive into patterns |
| Day 4 | Integration | 2 | Connect with other frameworks |
| Day 5 | Synthesis | 2 | Create commitment artifact |

## 🔑 Core Concepts

1. **Framework Foundation**: Understanding the historical context and design principles
2. **Architectural Impact**: How this framework influences system design decisions
3. **Implementation Strategy**: Practical steps for adoption in enterprise environments

## 💡 Practical Implementation (5 minutes)

Apply this week's learning:
- Document one architectural decision using this framework
- Evaluate current systems against framework principles
- Plan one implementation initiative

## 📊 ASCII Architecture

\`\`\`text
            Week `$weekNum: `$($cluster.Theme)
                    ↓
        ┌─────────────────────┐
        │  Core Principles    │
        └──────────┬──────────┘
                   ↓
        ┌─────────────────────┐
        │  Pattern Analysis   │
        └──────────┬──────────┘
                   ↓
        ┌─────────────────────┐
        │  Implementation     │
        └──────────┬──────────┘
                   ↓
        ┌─────────────────────┐
        │  Integration & Use  │
        └─────────────────────┘
\`\`\`

## 🎓 Success Criteria & Metrics

| Criterion | Indicator | Measurement |
|-----------|-----------|-------------|
| Understanding | Can articulate core principles | Clear written explanation |
| Application | Applied to real scenario | Documented use case |
| Integration | Integrated with other frameworks | Cross-reference document |
| Mastery | Ready for team guidance | Teaching notes created |

## 🔗 Related Topics

**Prereqs**: Phase01_Reboot completion  
**Builds Upon**: Enterprise SOLID principles  
**Enables**: Advanced architectural decisions  
**Cross-References**: Other Phase02 clusters

## Next Steps

Begin with Day 1: Understanding the foundational concepts.

---

**Phase02_Frameworks - Week $weekNum**  
**Status**: Ready for daily deep-dives  
**Last Updated**: October 19, 2025
"@
        
        Set-Content -Path $weekFile -Value $weekContent -Encoding UTF8
        $fileCount++
        
        # Create 5 daily files (01-05_Day##)
        for ($dayNum = 1; $dayNum -le 5; $dayNum++) {
            $dayTheme = $cluster.Days[$dayNum - 1]
            $dayFile = Join-Path $clusterPath "$($dayNum.ToString('00'))_Day$($dayNum.ToString('00'))_$($dayTheme).md"
            
            $dayContent = @"
# Day $dayNum`: $dayTheme

**Learning Level**: Advanced  
**Time**: 27 minutes (10 min concept + 10 min practice + 7 min reflection)  
**Week**: Week $weekNum | Cluster**: $($cluster.Name)

## 🎯 Today's Focus

Single learning objective for this 27-minute session focused on $($dayTheme.Replace('_', ' ').ToLower()).

## ⏱️ 27-Minute Breakdown

### Concept Explanation (10 minutes)
- Key principle or pattern
- Why it matters in enterprise architecture
- Real-world context

### Practical Application (10 minutes)
- Exercise or scenario
- Step-by-step implementation
- Validation approach

### Reflection & Integration (7 minutes)
- Journal reflection prompt
- Connection to previous learning
- Application in your context

## 🔍 Deep Dive

Detailed exploration of today's topic including:
- Core principles
- Implementation patterns
- Common pitfalls
- Best practices

## 💼 Evidence Artifact

**Deliverable**: Complete the daily reflection in your journal or portfolio template.

**Integration**: Document how this daily learning connects to the weekly theme.

## ✅ Daily Metrics

- [ ] Concept understood
- [ ] Practice exercise completed
- [ ] Reflection documented
- [ ] Integration with framework confirmed

## 🔗 Connection Points

- Previous day learning
- Related patterns from other clusters
- Enterprise application scenarios

## Next Steps

Proceed to Day `$($dayNum + 1) for the next progression in this week's learning.

---

**Phase02_Frameworks - Week $weekNum, Day $dayNum**  
**Learning Progression**: Week $weekNum of 9  
**Status**: Daily learning module  
**Last Updated**: October 19, 2025
"@
            
            Set-Content -Path $dayFile -Value $dayContent -Encoding UTF8
            $fileCount++
        }
        
        Write-Host "✓ Created $($cluster.Name) (6 files)" -ForegroundColor Green
    }
    
    # ═══════════════════════════════════════════════════════════
    # STEP 4: Create Phase02 README
    # ═══════════════════════════════════════════════════════════
    
    $phase02Readme = @"
# Phase02_Frameworks: Architectural Decision-Making & Patterns

**Status**: ✅ Structure created October 19, 2025  
**Learning Level**: Advanced (Lead Architect)  
**Total Content**: 54 files across 9 clusters  
**Estimated Time**: 45 hours (4.5 hours per cluster)  
**Model**: Based on Phase01_Reboot proven pattern

---

## 🎯 Phase Overview

Phase02_Frameworks focuses on architectural frameworks, design patterns, and decision-making methodologies that form the foundation of enterprise architecture leadership.

### Learning Journey

```
Cluster01: Decision Frameworks
    ↓
Cluster02: Repository Patterns
    ↓
Cluster03: CQRS & Event Sourcing
    ↓
Cluster04: Microservices Patterns
    ↓
Cluster05: Resilience Patterns
    ↓
Cluster06: Security Patterns
    ↓
Cluster07: Testing Patterns
    ↓
Cluster08: Monitoring & Observability
    ↓
Cluster09: Framework Integration & Declaration
```

## 📚 9 Learning Clusters

1. **Cluster01_Decision_Frameworks** - Architectural decision-making frameworks
2. **Cluster02_Repository_Patterns** - Data access and repository patterns
3. **Cluster03_CQRS_EventSourcing** - Command Query Responsibility Segregation
4. **Cluster04_Microservices_Patterns** - Microservices architecture patterns
5. **Cluster05_Resilience_Patterns** - Building resilient systems
6. **Cluster06_Security_Patterns** - Architectural security patterns
7. **Cluster07_Testing_Patterns** - Testing strategies and patterns
8. **Cluster08_Monitoring_Observability** - Monitoring and observability patterns
9. **Cluster09_Framework_Declaration** - Framework integration and commitment

## 🛠️ Portfolio Templates (10 Reusable)

Located in `01_Templates/`:

- Decision-Log.md
- Architecture-Decision-Record.md
- Repository-Implementation.md
- CQRS-Implementation-Canvas.md
- Microservice-Charter.md
- Resilience-Strategy.md
- Security-Checklist.md
- Test-Strategy-Document.md
- Observability-Dashboard.md
- Framework-Adoption-Playbook.md

## 📖 Learning Structure

**Per Cluster**:
- 1 Week Overview file (00_WeekXX) - 4.5 hours total
- 5 Daily Deep-Dive files (01-05_DayXX) - 27 minutes each
- Total: 6 files per cluster

**Per Phase**:
- 9 clusters
- 54 learning files
- 10 portfolio templates
- 45 hours total curriculum

## ✅ Learning Standards

- ✅ **27-Minute Sessions**: Each daily module optimized for focused learning
- ✅ **Weekly Sprints**: 5-day learning rhythm
- ✅ **175-Line Maximum**: All files comply with learning module standard
- ✅ **Portfolio Building**: Generate professional artifacts each week
- ✅ **Measurable Outcomes**: Success criteria embedded in every module

## 🔗 Integration with Phase01

Phase02 builds directly on Phase01_Reboot foundational mindset and discipline:

- Applies frameworks to the decision-making discipline
- Uses signal intelligence for pattern recognition
- Implements crafted quality through testing patterns
- Creates guardrails through security patterns

## 🚀 Next Steps

1. **Week 1**: Begin with Cluster01_Decision_Frameworks
2. **Each Day**: Complete one 27-minute learning loop
3. **Each Week**: Generate portfolio artifact using templates
4. **Week 9**: Create framework adoption declaration

---

**Phase02_Frameworks Learning Pathway**  
**Structure**: 9 clusters × 6 files = 54 learning modules  
**Target Audience**: Lead Architects, Enterprise Architects  
**Prerequisites**: Phase01_Reboot completion  
**Next Phase**: Phase03_Pattern_Studio

Last Updated: October 19, 2025
"@
    
    Set-Content -Path (Join-Path $BasePath "README.md") -Value $phase02Readme -Encoding UTF8
    Write-Host "✓ Created Phase02_Frameworks README" -ForegroundColor Green
    
    # ═══════════════════════════════════════════════════════════
    # SUMMARY REPORT
    # ═══════════════════════════════════════════════════════════
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   PHASE02_FRAMEWORKS STRUCTURE SUCCESSFULLY CREATED        ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📊 SUMMARY" -ForegroundColor Green
    Write-Host "  • Clusters created: 9" -ForegroundColor Green
    Write-Host "  • Content files created: 54 (6 per cluster)" -ForegroundColor Green
    Write-Host "  • Template files created: 10" -ForegroundColor Green
    Write-Host "  • Total files: 65" -ForegroundColor Green
    Write-Host ""
    Write-Host "📁 STRUCTURE" -ForegroundColor Green
    Write-Host "  Base: $BasePath" -ForegroundColor Gray
    Write-Host "  ├── 01_Templates/" -ForegroundColor Gray
    Write-Host "  │   ├── 10 portfolio templates" -ForegroundColor Gray
    Write-Host "  │   └── README.md" -ForegroundColor Gray
    Write-Host "  ├── Cluster01_Decision_Frameworks/" -ForegroundColor Gray
    Write-Host "  ├── Cluster02_Repository_Patterns/" -ForegroundColor Gray
    Write-Host "  ├── Cluster03_CQRS_EventSourcing/" -ForegroundColor Gray
    Write-Host "  ├── ... (6 more clusters)" -ForegroundColor Gray
    Write-Host "  ├── Cluster09_Framework_Declaration/" -ForegroundColor Gray
    Write-Host "  └── README.md" -ForegroundColor Gray
    Write-Host ""
    Write-Host "✨ NEXT STEPS" -ForegroundColor Yellow
    Write-Host "  1. Customize cluster names and themes as needed" -ForegroundColor Yellow
    Write-Host "  2. Review and enhance template content" -ForegroundColor Yellow
    Write-Host "  3. Add specific examples and use cases" -ForegroundColor Yellow
    Write-Host "  4. Create cross-references to Phase01 and ReferenceLibrary" -ForegroundColor Yellow
    Write-Host "  5. Validate 100% markdown compliance" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "⏱️  LEARNING TIME" -ForegroundColor Cyan
    Write-Host "  • Per cluster: 4.5 hours (10 × 27-minute loops)" -ForegroundColor Cyan
    Write-Host "  • Per phase: 45 hours (9 clusters)" -ForegroundColor Cyan
    Write-Host "  • Format: 27-minute focused learning sessions" -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Host "❌ ERROR: $_" -ForegroundColor Red
    exit 1
}
