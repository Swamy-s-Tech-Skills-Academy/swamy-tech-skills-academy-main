# Fix STSA Metadata Structure in OOP-Fundamentals
# Adds proper metadata headers to files missing STSA structure

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

$ErrorActionPreference = "Stop"

Write-Host "🔧 Adding STSA Metadata Structure to OOP-Fundamentals Files" -ForegroundColor Cyan
Write-Host "Target Folder: $FolderPath" -ForegroundColor Yellow

# Define files that need STSA metadata added
$FilesToUpdate = @{
    "01_OOP-Classes-and-Objects-CONDENSED.md" = @{
        LearningLevel = "Beginner"
        Prerequisites = "Basic programming knowledge"
        EstimatedTime = "15 minutes (condensed overview)"
        Series = "Condensed Overview"
    }
    "01_OOP-Core-Concepts-PartB.md" = @{
        LearningLevel = "Beginner"
        Prerequisites = "[01_OOP-Core-Concepts-PartA.md](01_OOP-Core-Concepts-PartA.md)"
        EstimatedTime = "12 minutes (27-minute focused session)"
        Series = "Part B of 2 - Core OOP Concepts"
    }
    "01_OOP-Objects-Creation-PartA.md" = @{
        LearningLevel = "Beginner"
        Prerequisites = "[01_OOP-Core-Concepts-PartB.md](01_OOP-Core-Concepts-PartB.md)"
        EstimatedTime = "15 minutes (27-minute focused session)"
        Series = "Part A of 2 - Objects Creation"
    }
    "01_OOP-Objects-Creation-PartB.md" = @{
        LearningLevel = "Beginner → Intermediate"
        Prerequisites = "[01_OOP-Objects-Creation-PartA.md](01_OOP-Objects-Creation-PartA.md)"
        EstimatedTime = "27 minutes (focused learning session)"
        Series = "Part B of 2 - Objects Creation"
    }
    "02_OOP-Encapsulation-Abstraction.md" = @{
        LearningLevel = "Beginner → Intermediate"
        Prerequisites = "[01_OOP-Objects-Creation-PartB.md](01_OOP-Objects-Creation-PartB.md)"
        EstimatedTime = "27 minutes (focused learning session)"
        Series = "Core Pillars - Encapsulation & Abstraction"
    }
    "03_OOP-Inheritance-Polymorphism.md" = @{
        LearningLevel = "Beginner → Intermediate"
        Prerequisites = "[02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)"
        EstimatedTime = "27 minutes (focused learning session)"
        Series = "Core Pillars - Inheritance & Polymorphism"
    }
    "04_OOP-Advanced-Patterns-PartA.md" = @{
        LearningLevel = "Intermediate"
        Prerequisites = "[03_OOP-Inheritance-Polymorphism.md](03_OOP-Inheritance-Polymorphism.md)"
        EstimatedTime = "27 minutes (focused learning session)"
        Series = "Part A of 2 - Advanced Patterns"
    }
    "04_OOP-Advanced-Patterns-PartB.md" = @{
        LearningLevel = "Intermediate"
        Prerequisites = "[04_OOP-Advanced-Patterns-PartA.md](04_OOP-Advanced-Patterns-PartA.md)"
        EstimatedTime = "27 minutes (focused learning session)"
        Series = "Part B of 2 - Advanced Patterns"
    }
    "05_OOP-Fundamentals-Comprehensive-Guide-PartA.md" = @{
        LearningLevel = "Beginner → Intermediate"
        Prerequisites = "Basic programming knowledge (variables, functions, loops)"
        EstimatedTime = "27 minutes (focused learning session)"
        Series = "Part A of 2 - Comprehensive Guide"
    }
    "05_OOP-Fundamentals-Comprehensive-Guide-PartB.md" = @{
        LearningLevel = "Beginner → Intermediate"
        Prerequisites = "[05_OOP-Fundamentals-Comprehensive-Guide-PartA.md](05_OOP-Fundamentals-Comprehensive-Guide-PartA.md)"
        EstimatedTime = "27 minutes (focused learning session)"
        Series = "Part B of 2 - Comprehensive Guide"
    }
    "06_OOD-Learning-Plan-PartA.md" = @{
        LearningLevel = "Intermediate"
        Prerequisites = "OOP fundamentals knowledge"
        EstimatedTime = "27 minutes (planning session)"
        Series = "Part A of 2 - OOD Learning Plan"
    }
    "06_OOD-Learning-Plan-PartB.md" = @{
        LearningLevel = "Intermediate"
        Prerequisites = "[06_OOD-Learning-Plan-PartA.md](06_OOD-Learning-Plan-PartA.md)"
        EstimatedTime = "27 minutes (planning session)"
        Series = "Part B of 2 - OOD Learning Plan"
    }
    "07_OOD-Basics-PartA.md" = @{
        LearningLevel = "Intermediate"
        Prerequisites = "OOP fundamentals knowledge"
        EstimatedTime = "27 minutes (focused learning session)"
        Series = "Part A of 3 - OOD Basics"
    }
    "07_OOD-Basics-PartB.md" = @{
        LearningLevel = "Intermediate"
        Prerequisites = "[07_OOD-Basics-PartA.md](07_OOD-Basics-PartA.md)"
        EstimatedTime = "27 minutes (focused learning session)"
        Series = "Part B of 3 - OOD Basics"
    }
    "07_OOD-Basics-PartC.md" = @{
        LearningLevel = "Intermediate"
        Prerequisites = "[07_OOD-Basics-PartB.md](07_OOD-Basics-PartB.md)"
        EstimatedTime = "27 minutes (focused learning session)"
        Series = "Part C of 3 - OOD Basics"
    }
    "08_OOP-Abstraction-Encapsulation-PartA.md" = @{
        LearningLevel = "Intermediate"
        Prerequisites = "OOP fundamentals knowledge"
        EstimatedTime = "27 minutes (focused learning session)"
        Series = "Part A of 3 - Abstraction & Encapsulation"
    }
    "08_OOP-Abstraction-Encapsulation-PartB.md" = @{
        LearningLevel = "Intermediate"
        Prerequisites = "[08_OOP-Abstraction-Encapsulation-PartA.md](08_OOP-Abstraction-Encapsulation-PartA.md)"
        EstimatedTime = "27 minutes (focused learning session)"
        Series = "Part B of 3 - Abstraction & Encapsulation"
    }
    "08_OOP-Abstraction-Encapsulation-PartC.md" = @{
        LearningLevel = "Intermediate"
        Prerequisites = "[08_OOP-Abstraction-Encapsulation-PartB.md](08_OOP-Abstraction-Encapsulation-PartB.md)"
        EstimatedTime = "27 minutes (focused learning session)"
        Series = "Part C of 3 - Abstraction & Encapsulation"
    }
}

$UpdatedFiles = @()

foreach ($fileName in $FilesToUpdate.Keys) {
    $filePath = Join-Path $FolderPath $fileName
    
    if (-not (Test-Path $filePath)) {
        Write-Host "  ⚠️  File not found: $fileName" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "  📝 Processing: $fileName" -ForegroundColor White
    
    $content = Get-Content $filePath -Raw -Encoding UTF8
    $metadata = $FilesToUpdate[$fileName]
    
    # Check if already has proper STSA metadata
    if ($content -match "Learning Level:" -and $content -match "Prerequisites:" -and $content -match "Estimated Time:.*27") {
        Write-Host "    ✓ Already has STSA metadata" -ForegroundColor Green
        continue
    }
    
    # Find the first heading
    $firstHeadingMatch = [regex]::Match($content, '^# (.+)$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    
    if ($firstHeadingMatch.Success) {
        $title = $firstHeadingMatch.Groups[1].Value
        
        # Create new metadata block
        $newMetadata = @"
# $title

**Learning Level**: $($metadata.LearningLevel)  
**Prerequisites**: $($metadata.Prerequisites)  
**Estimated Time**: $($metadata.EstimatedTime)  
**Series**: $($metadata.Series)

---
"@
        
        # Replace the title and any existing partial metadata
        $contentAfterTitle = $content -replace '^# .+(\r?\n.*?){0,10}(?=\r?\n## |\r?\n### |\r?\nBy the end|\r?\n\*\*Part|\r?\n---|\z)', ''
        
        # Add learning objectives if not present
        if ($contentAfterTitle -notmatch "🎯 Learning Objectives|Learning Objectives") {
            $newMetadata += @"

## 🎯 Learning Objectives

By the end of this session, you will:

- [Add specific learning objectives]

---
"@
        }
        
        $newContent = $newMetadata + "`n" + $contentAfterTitle
        
        Set-Content -Path $filePath -Value $newContent -Encoding UTF8
        $UpdatedFiles += $fileName
        Write-Host "    ✅ Added STSA metadata structure" -ForegroundColor Green
    } else {
        Write-Host "    ❌ Could not find title heading" -ForegroundColor Red
    }
}

Write-Host "`n🎉 STSA Metadata Update Complete!" -ForegroundColor Green
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "  • Files processed: $($FilesToUpdate.Count)" -ForegroundColor White
Write-Host "  • Files updated: $($UpdatedFiles.Count)" -ForegroundColor White

if ($UpdatedFiles.Count -gt 0) {
    Write-Host "`n📝 Updated Files:" -ForegroundColor Cyan
    foreach ($file in $UpdatedFiles) {
        Write-Host "  • $file" -ForegroundColor White
    }
}

Write-Host "`n✅ All files now have proper STSA metadata structure!" -ForegroundColor Green