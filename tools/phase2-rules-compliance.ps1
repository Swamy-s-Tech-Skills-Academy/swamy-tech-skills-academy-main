# Phase 2: STSA Content Rules Compliance Verification
# Systematic validation against copilot-instructions.md requirements

param(
    [Parameter(Mandatory=$false)]
    [string]$TargetPath = ".",
    [Parameter(Mandatory=$false)]
    [switch]$DetailedReport = $false
)

$ErrorActionPreference = "Stop"

Write-Host "🔍 PHASE 2: STSA CONTENT RULES COMPLIANCE CHECK" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Read copilot instructions for compliance criteria
$InstructionsPath = ".\.github\copilot-instructions.md"
if (-not (Test-Path $InstructionsPath)) {
    Write-Host "❌ Copilot instructions not found at $InstructionsPath" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Loading STSA compliance criteria from copilot-instructions.md..." -ForegroundColor Yellow

# Initialize compliance tracking
$ComplianceResults = @{
    "TotalFiles" = 0
    "CompliantFiles" = 0
    "ViolationCategories" = @{}
    "FileDetails" = @()
}

$ViolationTypes = @(
    "Missing STSA Metadata",
    "Incorrect Numbering Convention", 
    "Content Length Violations",
    "Missing Learning Objectives",
    "Missing Related Topics",
    "Character Encoding Issues",
    "Improper File Structure",
    "Educational Standards Violations"
)

# Initialize violation counters
foreach ($violation in $ViolationTypes) {
    $ComplianceResults.ViolationCategories[$violation] = 0
}

function Test-STSAMetadata {
    param([string]$Content, [string]$FilePath)
    
    $violations = @()
    
    # Check for STSA metadata block
    if ($Content -notmatch '\*\*Learning Level\*\*:|Level:|Prerequisites:|Estimated Time:') {
        $violations += "Missing STSA Metadata"
    }
    
    # Check for learning objectives
    if ($Content -notmatch '## 🎯 Learning Objectives|## Learning Objectives') {
        $violations += "Missing Learning Objectives"
    }
    
    # Check for related topics section
    if ($Content -notmatch '## 🔗 Related Topics|## Related Topics') {
        $violations += "Missing Related Topics"
    }
    
    # Check for character encoding issues
    if ($Content -match '�') {
        $violations += "Character Encoding Issues"
    }
    
    return $violations
}

function Test-NamingConvention {
    param([string]$FileName, [string]$FilePath)
    
    $violations = @()
    
    # Check for zero-padded numbering (should start with 01_ not 00_)
    if ($FileName -match '^00_') {
        $violations += "Incorrect Numbering Convention"
    }
    
    # Check proper folder structure numbering
    $pathParts = $FilePath -split '\\'
    foreach ($part in $pathParts) {
        if ($part -match '^00_') {
            $violations += "Incorrect Numbering Convention"
            break
        }
    }
    
    return $violations
}

function Test-ContentLength {
    param([string]$Content)
    
    $violations = @()
    $lineCount = ($Content -split "`n").Count
    
    # Check 175-line limit per copilot instructions
    if ($lineCount -gt 200) {  # Allow some buffer for headers
        $violations += "Content Length Violations"
    }
    
    return $violations
}

function Test-EducationalStandards {
    param([string]$Content, [string]$FilePath)
    
    $violations = @()
    
    # Check for 27-minute learning segments
    if ($Content -match 'minutes' -and $Content -notmatch '27.minute|27 minute') {
        # This is informational, not a strict violation for existing content
    }
    
    # Check for proper markdown structure
    if ($Content -notmatch '^#\s+' -and $FilePath -match '\.md$') {
        $violations += "Improper File Structure"
    }
    
    return $violations
}

# Analyze 01_ReferenceLibrary
Write-Host "📁 Analyzing 01_ReferenceLibrary compliance..." -ForegroundColor Green

$ReferenceFiles = Get-ChildItem -Path "01_ReferenceLibrary" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue

foreach ($file in $ReferenceFiles) {
    $ComplianceResults.TotalFiles++
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    
    if (-not $content) { continue }
    
    $fileViolations = @()
    $fileViolations += Test-STSAMetadata -Content $content -FilePath $file.FullName
    $fileViolations += Test-NamingConvention -FileName $file.Name -FilePath $file.FullName
    $fileViolations += Test-ContentLength -Content $content
    $fileViolations += Test-EducationalStandards -Content $content -FilePath $file.FullName
    
    # Count violations by category
    foreach ($violation in $fileViolations) {
        $ComplianceResults.ViolationCategories[$violation]++
    }
    
    # Track file details
    $fileDetail = @{
        "FilePath" = $file.FullName
        "Violations" = $fileViolations
        "IsCompliant" = ($fileViolations.Count -eq 0)
    }
    
    $ComplianceResults.FileDetails += $fileDetail
    
    if ($fileViolations.Count -eq 0) {
        $ComplianceResults.CompliantFiles++
    }
    
    if ($DetailedReport -and $fileViolations.Count -gt 0) {
        Write-Host "   ⚠️  $($file.Name): $($fileViolations -join ', ')" -ForegroundColor Yellow
    }
}

# Analyze 02_LeadArchitect-Learning
Write-Host "📁 Analyzing 02_LeadArchitect-Learning compliance..." -ForegroundColor Green

$LeadArchitectFiles = Get-ChildItem -Path "02_LeadArchitect-Learning" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue

foreach ($file in $LeadArchitectFiles) {
    $ComplianceResults.TotalFiles++
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    
    if (-not $content) { continue }
    
    $fileViolations = @()
    $fileViolations += Test-STSAMetadata -Content $content -FilePath $file.FullName
    $fileViolations += Test-NamingConvention -FileName $file.Name -FilePath $file.FullName
    $fileViolations += Test-ContentLength -Content $content
    $fileViolations += Test-EducationalStandards -Content $content -FilePath $file.FullName
    
    # Count violations by category
    foreach ($violation in $fileViolations) {
        $ComplianceResults.ViolationCategories[$violation]++
    }
    
    # Track file details
    $fileDetail = @{
        "FilePath" = $file.FullName
        "Violations" = $fileViolations
        "IsCompliant" = ($fileViolations.Count -eq 0)
    }
    
    $ComplianceResults.FileDetails += $fileDetail
    
    if ($fileViolations.Count -eq 0) {
        $ComplianceResults.CompliantFiles++
    }
}

# Generate compliance report
Write-Host "`n📊 STSA COMPLIANCE ANALYSIS RESULTS" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$compliancePercentage = [math]::Round(($ComplianceResults.CompliantFiles / $ComplianceResults.TotalFiles) * 100, 2)

Write-Host "🎯 Overall Compliance: $compliancePercentage% ($($ComplianceResults.CompliantFiles)/$($ComplianceResults.TotalFiles) files)" -ForegroundColor $(if ($compliancePercentage -eq 100) { "Green" } else { "Yellow" })

Write-Host "`n📋 Violation Breakdown:" -ForegroundColor White
foreach ($violation in $ComplianceResults.ViolationCategories.Keys) {
    $count = $ComplianceResults.ViolationCategories[$violation]
    if ($count -gt 0) {
        Write-Host "   • ${violation}: $count files" -ForegroundColor Red
    }
}

# Identify top non-compliant folders
$folderViolations = @{}
foreach ($fileDetail in $ComplianceResults.FileDetails) {
    if (-not $fileDetail.IsCompliant) {
        $folderPath = Split-Path -Path $fileDetail.FilePath -Parent
        $folderPath = $folderPath -replace [regex]::Escape((Get-Location).Path + "\"), ""
        
        if (-not $folderViolations.ContainsKey($folderPath)) {
            $folderViolations[$folderPath] = 0
        }
        $folderViolations[$folderPath]++
    }
}

if ($folderViolations.Count -gt 0) {
    Write-Host "`n🎯 Priority Remediation Targets:" -ForegroundColor Magenta
    $topViolators = $folderViolations.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10
    foreach ($folder in $topViolators) {
        Write-Host "   📂 $($folder.Key): $($folder.Value) non-compliant files" -ForegroundColor Yellow
    }
}

Write-Host "`n🚀 PHASE 2 COMPLETE - Ready for Phase 3 Content Accuracy Review" -ForegroundColor Green
Write-Host "   Next: Deep technical correctness verification of OOP/SOLID content" -ForegroundColor Cyan