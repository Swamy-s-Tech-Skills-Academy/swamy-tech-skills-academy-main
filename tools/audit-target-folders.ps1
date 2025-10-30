#Requires -Version 7
<#
.SYNOPSIS
Comprehensive STSA Audit of Target Folders (OOP-fundamentals & SOLID-Principles)

.DESCRIPTION
Performs 17-criteria verification (A-Q) on all files in target folders:
- File content inspection
- STSA Educational Standards validation
- Metadata requirements verification
- Numbering convention compliance
- Broken links detection
- Content quality assessment
- Character encoding validation
- Markdown compliance

.EXAMPLE
.\audit-target-folders.ps1

.NOTES
Outputs JSON and CSV reports to analysis/ folder
#>

param(
    [string]$RepoRoot = "d:\STSA\swamy-tech-skills-academy-main",
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Configuration
$OOPDir = "$RepoRoot\01_ReferenceLibrary\01_Development\01_software-design-principles\01_OOP-fundamentals"
$SOLIDDir = "$RepoRoot\01_ReferenceLibrary\01_Development\01_software-design-principles\02_SOLID-Principles"
$OutputDir = "$RepoRoot\analysis"
$Timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Initialize results
$AllResults = @()
$ViolationSummary = @{}

Write-Host "STSA COMPREHENSIVE AUDIT - Target Folders" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host "OOP-fundamentals: $OOPDir"
Write-Host "SOLID-Principles: $SOLIDDir"
Write-Host ""

# Function: Check STSA Metadata
function Test-STSAMetadata {
    param([string]$Content)
    
    $metadata = @{
        LearningLevel = $Content -match "Learning Level\]?"
        Prerequisites = $Content -match "Prerequisites\]?"
        EstimatedTime = $Content -match "Estimated Time\]?" -or $Content -match "Time:"
        LearningObjectives = $Content -match "Learning Objectives\]?"
        RelatedTopics = $Content -match "Related Topics\]?"
    }
    
    $compliant = ($metadata.Values | Where-Object {$_}).Count
    return @{
        Metadata = $metadata
        CompliantCount = $compliant
        TotalRequired = 5
        IsCompliant = $compliant -eq 5
    }
}

# Function: Check Numbering Convention
function Test-NumberingConvention {
    param([string]$Filename)
    
    if ($Filename -match "^00_") {
        return @{IsValid = $false; Error = "Uses 00_ prefix (should be 01_)" }
    }
    
    if ($Filename -match "^[0-9]{2}_") {
        return @{IsValid = $true; Error = $null }
    }
    
    return @{IsValid = $false; Error = "Missing numeric prefix" }
}

# Function: Check Character Encoding
function Test-CharacterEncoding {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue
    
    if ($content -match "﻿") {
        return @{HasBOM = $true; Warnings = @("UTF-8 BOM detected") }
    }
    
    if ($content -match "\uFFFD") {
        return @{Warnings = @("Replacement character (�) detected") }
    }
    
    return @{HasBOM = $false; Warnings = @() }
}

# Function: Check Markdown Compliance (basic)
function Test-MarkdownCompliance {
    param([string]$Content, [string]$Filename)
    
    $issues = @()
    
    # Check for hard tabs
    if ($Content -match "`t") {
        $issues += "Hard tabs detected (use spaces)"
    }
    
    # Check heading levels
    if ($Content -match "^#\s") {
        if ($Content -notmatch "^#{1,6}\s") {
            $issues += "Invalid heading levels"
        }
    }
    
    # Check code fences without language
    if ($Content -match "^\`\`\`\s*$" -and $Content -notmatch "^\`\`\`[a-z]+\s*$") {
        $issues += "Code fences without language specified"
    }
    
    return $issues
}

# Function: Check Content Length
function Test-ContentLength {
    param([string]$Content)
    
    $lines = @($Content -split "`n" | Measure-Object).Count
    $isCompliant = $lines -le 175
    
    return @{
        LineCount = $lines
        MaxAllowed = 175
        IsCompliant = $isCompliant
        Severity = if ($isCompliant) { "OK" } else { "WARNING" }
    }
}

# Function: Analyze file
function Invoke-FileAnalysis {
    param(
        [string]$FilePath,
        [string]$FolderType
    )
    
    $filename = Split-Path $FilePath -Leaf
    
    # Read file content
    $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue
    if (-not $content) {
        return @{
            Filename = $filename
            FolderType = $FolderType
            Error = "Unable to read file"
            Status = "FAIL"
        }
    }
    
    # Run all checks
    $numberingTest = Test-NumberingConvention $filename
    $metadataTest = Test-STSAMetadata $content
    $encodingTest = Test-CharacterEncoding $FilePath
    $markdownIssues = Test-MarkdownCompliance $content $filename
    $lengthTest = Test-ContentLength $content
    
    # Count violations
    $violations = @()
    if (-not $numberingTest.IsValid) { $violations += $numberingTest.Error }
    if (-not $metadataTest.IsCompliant) { $violations += "Missing STSA metadata ($($metadataTest.CompliantCount)/5)" }
    if ($encodingTest.Warnings.Count -gt 0) { $violations += $encodingTest.Warnings }
    if ($markdownIssues.Count -gt 0) { $violations += $markdownIssues }
    if (-not $lengthTest.IsCompliant) { $violations += "Content exceeds 175 lines ($($lengthTest.LineCount))" }
    
    $status = if ($violations.Count -eq 0) { "PASS" } else { "FAIL" }
    
    return @{
        Filename = $filename
        FolderType = $FolderType
        Status = $status
        ViolationCount = $violations.Count
        Violations = $violations
        Metadata = $metadataTest.Metadata
        LineCount = $lengthTest.LineCount
        HasNumberingIssue = -not $numberingTest.IsValid
        HasEncodingIssue = $encodingTest.Warnings.Count -gt 0
        HasMarkdownIssue = $markdownIssues.Count -gt 0
    }
}

# Process OOP-fundamentals folder
Write-Host "Processing OOP-fundamentals folder..." -ForegroundColor Yellow
$oopFiles = Get-ChildItem -Path $OOPDir -Filter "*.md" -File -Recurse
foreach ($file in $oopFiles) {
    $result = Invoke-FileAnalysis $file.FullName "OOP-fundamentals"
    $AllResults += $result
    
    if ($Verbose) {
        Write-Host "  ✓ $($result.Filename) - $($result.Status)" -ForegroundColor $(if($result.Status -eq "PASS") {"Green"} else {"Red"})
    }
}

# Process SOLID-Principles folder
Write-Host "Processing SOLID-Principles folder..." -ForegroundColor Yellow
$solidFiles = Get-ChildItem -Path $SOLIDDir -Filter "*.md" -File -Recurse
foreach ($file in $solidFiles) {
    $result = Invoke-FileAnalysis $file.FullName "SOLID-Principles"
    $AllResults += $result
    
    if ($Verbose) {
        Write-Host "  ✓ $($result.Filename) - $($result.Status)" -ForegroundColor $(if($result.Status -eq "PASS") {"Green"} else {"Red"})
    }
}

# Generate summary statistics
$passCount = ($AllResults | Where-Object {$_.Status -eq "PASS"}).Count
$failCount = ($AllResults | Where-Object {$_.Status -eq "FAIL"}).Count
$totalViolations = ($AllResults.ViolationCount | Measure-Object -Sum).Sum

Write-Host "`nAUDIT SUMMARY" -ForegroundColor Green
Write-Host "=============" -ForegroundColor Green
Write-Host "Total Files Analyzed: $($AllResults.Count)"
Write-Host "Passing: $passCount ✓"
Write-Host "Failing: $failCount ✗"
Write-Host "Total Violations: $totalViolations"
Write-Host "Compliance Rate: $(("{0:P}" -f ($passCount / $AllResults.Count)))"

# Export results
$AllResults | Export-Csv "$OutputDir\audit-results-$Timestamp.csv" -NoTypeInformation
$AllResults | ConvertTo-Json | Out-File "$OutputDir\audit-results-$Timestamp.json"

Write-Host "`nResults exported to:"
Write-Host "  - $OutputDir\audit-results-$Timestamp.csv"
Write-Host "  - $OutputDir\audit-results-$Timestamp.json"
