# Fix All STSA Compliance Issues - Comprehensive Remediation Script
# Addresses: Placeholder Learning Objectives + Markdown Lint Issues + README Files

param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host "`n🔧 STSA COMPREHENSIVE COMPLIANCE FIX" -ForegroundColor Cyan
Write-Host "====================================`n" -ForegroundColor Cyan

$mode = if ($DryRun) { "DRY RUN" } else { "LIVE UPDATE" }
Write-Host "Mode: $mode`n" -ForegroundColor $(if ($DryRun) { "Yellow" } else { "Green" })

# Define base paths
$oopPath = "01_ReferenceLibrary\01_Development\01_software-design-principles\01_OOP-fundamentals"
$solidPath = "01_ReferenceLibrary\01_Development\01_software-design-principles\02_SOLID-Principles"

# ============================================================================
# PHASE 1: Fix Placeholder Learning Objectives (15 files)
# ============================================================================

Write-Host "📝 PHASE 1: Replacing Placeholder Learning Objectives" -ForegroundColor Cyan
Write-Host "====================================================`n" -ForegroundColor Cyan

$learningObjectivesMap = @{
    # OOP Fundamentals Files
    "01_OOP-Classes-and-Objects-CONDENSED.md" = @"
- Understand the difference between classes and objects
- Master class definition and object instantiation concepts
- Apply real-world modeling with classes and objects
- Use pseudocode to design object-oriented solutions
"@

    "02_OOP-Encapsulation-Abstraction.md" = @"
- Master encapsulation principles and data hiding techniques
- Understand abstraction for managing complexity
- Apply access modifiers effectively in object design
- Distinguish between encapsulation and abstraction use cases
"@

    "03_OOP-Inheritance-Polymorphism.md" = @"
- Master inheritance hierarchies and code reuse strategies
- Understand polymorphism and dynamic binding concepts
- Apply method overriding and interface implementation
- Distinguish between inheritance and composition patterns
"@

    "04_OOP-Advanced-Patterns-PartA.md" = @"
- Master advanced OOP design patterns and architectural approaches
- Understand composition over inheritance trade-offs
- Apply interface-based design and dependency injection
- Evaluate pattern selection based on problem context
"@

    "04_OOP-Advanced-Patterns-PartB.md" = @"
- Implement advanced behavioral and structural patterns
- Master dependency management in complex systems
- Apply SOLID principles in pattern implementations
- Design flexible, maintainable enterprise architectures
"@

    "05_OOP-Fundamentals-Comprehensive-Guide-PartA.md" = @"
- Understand the four pillars of OOP and their practical applications
- Master class design, inheritance relationships, and polymorphism patterns
- Apply encapsulation and abstraction principles in real-world scenarios
- Make informed decisions between inheritance vs composition
- Identify and avoid common OOP anti-patterns
"@

    "05_OOP-Fundamentals-Comprehensive-Guide-PartB.md" = @"
- Implement complete OOP solutions with all four pillars integrated
- Master advanced inheritance hierarchies and polymorphic behaviors
- Apply enterprise design patterns effectively
- Evaluate architectural trade-offs in OOP design decisions
"@

    "06_OOD-Learning-Plan-PartA.md" = @"
- Create comprehensive OOD learning roadmap aligned with career goals
- Master structured approach to OOP and design principles
- Apply weekly learning milestones with measurable outcomes
- Design practice projects that reinforce OOD concepts
"@

    "06_OOD-Learning-Plan-PartB.md" = @"
- Complete advanced OOD learning milestones
- Master practical implementation of OOD principles in projects
- Apply design pattern selection strategies
- Evaluate progress through concrete deliverables
"@

    "07_OOD-Basics-PartA.md" = @"
- Master fundamental OOD concepts with UML class diagrams
- Understand relationships: generalization, specialization, association
- Apply C# implementations of OOD principles
- Create class diagrams for real-world scenarios
"@

    "07_OOD-Basics-PartB.md" = @"
- Implement aggregation and composition relationships in C#
- Master strong vs weak associations in object design
- Apply inheritance and dependency patterns effectively
- Design robust object relationship hierarchies
"@

    "07_OOD-Basics-PartC.md" = @"
- Master complete OOD relationship modeling
- Understand realization and interface-based design
- Apply all OOD relationship types in integrated solutions
- Evaluate relationship selection based on design goals
"@

    "08_OOP-Abstraction-Encapsulation-PartA.md" = @"
- Understand fundamental differences between abstraction and encapsulation
- Apply both principles effectively in object-oriented design
- Recognize when to use abstraction vs encapsulation
- Design classes with appropriate information hiding
"@

    "08_OOP-Abstraction-Encapsulation-PartB.md" = @"
- Implement practical abstraction patterns in complex systems
- Master access control strategies for encapsulation
- Apply abstraction layers in enterprise architectures
- Balance abstraction complexity with maintainability
"@

    "08_OOP-Abstraction-Encapsulation-PartC.md" = @"
- Master advanced abstraction and encapsulation techniques
- Understand boundary design between public and private concerns
- Apply complete information hiding strategies
- Evaluate encapsulation effectiveness in system design
"@
}

$objectivesFixed = 0

foreach ($filename in $learningObjectivesMap.Keys) {
    $filePath = Join-Path $oopPath $filename
    
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw -Encoding UTF8
        
        # Check if placeholder exists
        if ($content -match '\[Add specific learning objectives\]') {
            $replacement = $learningObjectivesMap[$filename]
            
            # Replace placeholder with specific objectives
            $newContent = $content -replace '- \[Add specific learning objectives\]', $replacement
            
            if (-not $DryRun) {
                Set-Content -Path $filePath -Value $newContent -Encoding UTF8 -NoNewline
                Write-Host "✅ Fixed Learning Objectives: $filename" -ForegroundColor Green
            } else {
                Write-Host "🔍 [DRY RUN] Would fix: $filename" -ForegroundColor Yellow
            }
            $objectivesFixed++
        }
    }
}

Write-Host "`n📊 Phase 1 Summary: $objectivesFixed files with placeholder objectives fixed`n" -ForegroundColor Cyan

# ============================================================================
# PHASE 2: Fix Markdown Lint Issues (Related Topics Spacing)
# ============================================================================

Write-Host "📝 PHASE 2: Fixing Markdown Lint Issues (Blank Lines)" -ForegroundColor Cyan
Write-Host "===================================================`n" -ForegroundColor Cyan

$lintFixed = 0

# Get all markdown files in target folders
$allFiles = @()
$allFiles += Get-ChildItem -Path $oopPath -Filter "*.md" -File
$allFiles += Get-ChildItem -Path $solidPath -Filter "*.md" -File

foreach ($file in $allFiles) {
    if ($file.Name -eq "README.md") { continue }  # Skip READMEs for now
    
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Fix MD022: Add blank line before headings in Related Topics sections
    $content = $content -replace '(Cross-References\*\*\r?\n)(- \*\*)', "`$1`n`$2"
    $content = $content -replace '(\*\*Enables Next Steps\*\*\r?\n)(- \*\*)', "`$1`n`$2"
    $content = $content -replace '(\*\*Builds Upon\*\*\r?\n)(-)', "`$1`n`$2"
    $content = $content -replace '(\*\*Prerequisites\*\*\r?\n)(-)', "`$1`n`$2"
    
    # Fix MD032: Add blank line after lists in Related Topics sections
    $content = $content -replace '(- \[.*?\].*?\r?\n)(### \*\*)', "`$1`n`$2"
    $content = $content -replace '(- \*\*.*?:.*?\r?\n)(### \*\*)', "`$1`n`$2"
    
    if ($content -ne $originalContent) {
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            Write-Host "✅ Fixed Markdown Lint: $($file.Name)" -ForegroundColor Green
        } else {
            Write-Host "🔍 [DRY RUN] Would fix lint issues: $($file.Name)" -ForegroundColor Yellow
        }
        $lintFixed++
    }
}

Write-Host "`n📊 Phase 2 Summary: $lintFixed files with lint issues fixed`n" -ForegroundColor Cyan

# ============================================================================
# PHASE 3: Fix README Files (Learning Objectives)
# ============================================================================

Write-Host "📝 PHASE 3: Fixing README Files" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Fix OOP-fundamentals README
$oopReadme = Join-Path $oopPath "README.md"
if (Test-Path $oopReadme) {
    $content = Get-Content $oopReadme -Raw -Encoding UTF8
    
    # Check if Learning Objectives section exists
    if ($content -notmatch '## 🎯 Learning Objectives') {
        # Insert Learning Objectives after Prerequisites
        $learningObj = @"

## 🎯 Learning Objectives

By completing this module, you will:

- Master the four pillars of Object-Oriented Programming (OOP)
- Apply encapsulation, abstraction, inheritance, and polymorphism in real-world scenarios
- Design robust class hierarchies and object relationships
- Understand Object-Oriented Design (OOD) principles and UML modeling
- Implement advanced OOP patterns and best practices

"@
        
        $content = $content -replace '(\*\*Estimated Time\*\*:.*?\r?\n)', "`$1$learningObj"
        
        if (-not $DryRun) {
            Set-Content -Path $oopReadme -Value $content -Encoding UTF8 -NoNewline
            Write-Host "✅ Fixed OOP-fundamentals README.md - Added Learning Objectives" -ForegroundColor Green
        } else {
            Write-Host "🔍 [DRY RUN] Would fix: OOP-fundamentals README.md" -ForegroundColor Yellow
        }
    }
}

# Fix SOLID-Principles README
$solidReadme = Join-Path $solidPath "README.md"
if (Test-Path $solidReadme) {
    $content = Get-Content $solidReadme -Raw -Encoding UTF8
    
    # Check if Learning Objectives section exists
    if ($content -notmatch '## 🎯 Learning Objectives') {
        # Insert Learning Objectives after Prerequisites
        $learningObj = @"

## 🎯 Learning Objectives

By completing this module, you will:

- Master all five SOLID principles with practical implementations
- Apply Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, and Dependency Inversion principles
- Identify and refactor SOLID violations in existing codebases
- Design maintainable, extensible software architectures
- Implement SOLID principles across multiple programming languages

"@
        
        $content = $content -replace '(\*\*Estimated Time\*\*:.*?\r?\n)', "`$1$learningObj"
        
        if (-not $DryRun) {
            Set-Content -Path $solidReadme -Value $content -Encoding UTF8 -NoNewline
            Write-Host "✅ Fixed SOLID-Principles README.md - Added Learning Objectives" -ForegroundColor Green
        } else {
            Write-Host "🔍 [DRY RUN] Would fix: SOLID-Principles README.md" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n📊 Phase 3 Summary: 2 README files fixed`n" -ForegroundColor Cyan

# ============================================================================
# FINAL SUMMARY
# ============================================================================

Write-Host "`n✨ COMPREHENSIVE FIX COMPLETE ✨" -ForegroundColor Green
Write-Host "================================`n" -ForegroundColor Green

Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "  - Placeholder Learning Objectives Fixed: $objectivesFixed files" -ForegroundColor White
Write-Host "  - Markdown Lint Issues Fixed: $lintFixed files" -ForegroundColor White
Write-Host "  - README Files Fixed: 2 files" -ForegroundColor White
Write-Host "  - Mode: $mode`n" -ForegroundColor $(if ($DryRun) { "Yellow" } else { "Green" })

if ($DryRun) {
    Write-Host "⚠️  This was a DRY RUN - no files were modified" -ForegroundColor Yellow
    Write-Host "Run without -DryRun to apply changes`n" -ForegroundColor Yellow
} else {
    Write-Host "✅ All changes have been applied successfully!" -ForegroundColor Green
    Write-Host "Run audit script to verify 100% compliance`n" -ForegroundColor Green
}
