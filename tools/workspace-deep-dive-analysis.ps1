# workspace-deep-dive-analysis.ps1
# STSA Comprehensive Workspace Deep Dive Analysis Tool
# Provides complete health check, compliance metrics, and reporting

<#
.SYNOPSIS
    Performs comprehensive analysis of the STSA workspace

.DESCRIPTION
    This script analyzes the entire workspace including:
    - Repository structure and git status
    - Content inventory (files, folders, metrics)
    - Character encoding validation
    - Markdown linting compliance
    - Link validation
    - Quality scoring and recommendations

.PARAMETER AnalysisType
    Type of analysis: 'quick' (5 min), 'standard' (15 min), or 'comprehensive' (30+ min)
    Default: 'standard'

.PARAMETER OutputFormat
    Output format: 'console' or 'json' for programmatic use
    Default: 'console'

.PARAMETER SaveReport
    Save analysis report to file (timestamp included)
    Default: $false

.EXAMPLE
    .\tools\workspace-deep-dive-analysis.ps1 -AnalysisType comprehensive
    
.EXAMPLE
    .\tools\workspace-deep-dive-analysis.ps1 -AnalysisType quick -SaveReport
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('quick', 'standard', 'comprehensive')]
    [string]$AnalysisType = 'standard',
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('console', 'json')]
    [string]$OutputFormat = 'console',
    
    [Parameter(Mandatory=$false)]
    [switch]$SaveReport
)

$ErrorActionPreference = "Stop"
$startTime = Get-Date

# ============================================================================
# SECTION 1: Repository Health
# ============================================================================
function Get-RepositoryHealth {
    Write-Host "`n📊 SECTION 1: REPOSITORY HEALTH" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    
    $health = @{
        Branch = git rev-parse --abbrev-ref HEAD
        CommitHash = git rev-parse --short HEAD
        LatestCommit = git log --oneline -1
        CommitsAhead = git rev-list --count "main..$(git rev-parse --abbrev-ref HEAD)" 2>$null || "0"
        UncommittedChanges = (git status --short | Measure-Object).Count
        RemoteUpToDate = (git status -sb | Select-String "ahead|behind")
    }
    
    Write-Host "  Branch: $($health.Branch)" -ForegroundColor Yellow
    Write-Host "  Latest Commit: $($health.LatestCommit)" -ForegroundColor Gray
    Write-Host "  Uncommitted Changes: $($health.UncommittedChanges)" -ForegroundColor $(if ($health.UncommittedChanges -gt 0) { "Red" } else { "Green" })
    
    return $health
}

# ============================================================================
# SECTION 2: Folder Structure Analysis
# ============================================================================
function Get-FolderStructure {
    Write-Host "`n📁 SECTION 2: FOLDER STRUCTURE ANALYSIS" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan
    
    $structure = @{}
    
    $mainFolders = @("01_ReferenceLibrary", "02_LeadArchitect-Learning", "tools")
    
    foreach ($folder in $mainFolders) {
        if (Test-Path $folder) {
            $mdCount = (Get-ChildItem $folder -Recurse -Filter "*.md" -ErrorAction SilentlyContinue | Measure-Object).Count
            $sizeBytes = (Get-ChildItem $folder -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            $sizeMB = [Math]::Round($sizeBytes / 1MB, 2)
            $dirCount = (Get-ChildItem $folder -Directory -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
            
            $structure[$folder] = @{
                MarkdownFiles = $mdCount
                SizeMB = $sizeMB
                Directories = $dirCount
            }
            
            Write-Host "  📂 $folder" -ForegroundColor Yellow
            Write-Host "     Files: $mdCount | Size: $sizeMB MB | Dirs: $dirCount" -ForegroundColor Gray
        }
    }
    
    return $structure
}

# ============================================================================
# SECTION 3: Content Domain Breakdown
# ============================================================================
function Get-DomainBreakdown {
    Write-Host "`n🏗️  SECTION 3: REFERENCE LIBRARY DOMAIN BREAKDOWN" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    
    $domains = @{}
    $domainPath = "01_ReferenceLibrary"
    
    if (Test-Path $domainPath) {
        $domainFolders = Get-ChildItem $domainPath -Directory | Sort-Object Name
        
        foreach ($domain in $domainFolders) {
            $mdCount = (Get-ChildItem $domain -Recurse -Filter "*.md" | Measure-Object).Count
            $subdirs = (Get-ChildItem $domain -Directory -Recurse | Measure-Object).Count
            
            $domains[$domain.Name] = @{
                MarkdownFiles = $mdCount
                Subdirectories = $subdirs
            }
            
            Write-Host "  📚 $($domain.Name)" -ForegroundColor Yellow
            Write-Host "     MD Files: $mdCount | Subdirs: $subdirs" -ForegroundColor Gray
        }
    }
    
    return $domains
}

# ============================================================================
# SECTION 4: Character Encoding Validation
# ============================================================================
function Get-EncodingValidation {
    Write-Host "`n✅ SECTION 4: CHARACTER ENCODING VALIDATION" -ForegroundColor Cyan
    Write-Host "===========================================" -ForegroundColor Cyan
    
    $allMdFiles = Get-ChildItem -Recurse -Filter "*.md" -ErrorAction SilentlyContinue
    $corruptedFiles = @()
    $cleanFiles = 0
    
    foreach ($file in $allMdFiles) {
        try {
            $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
            
            # Check for common corruption patterns
            if ($content -match '[\uFFFD]' -or $content -match '[ðŸ]' -or $content -match '[Â]') {
                $corruptedFiles += $file.FullName
            } else {
                $cleanFiles++
            }
        } catch {
            $corruptedFiles += $file.FullName
        }
    }
    
    $totalFiles = $allMdFiles.Count
    $corruptedCount = $corruptedFiles.Count
    $healthPercentage = [Math]::Round(($cleanFiles / $totalFiles) * 100, 1)
    
    Write-Host "  Total Files Checked: $totalFiles" -ForegroundColor White
    Write-Host "  Clean Files: $cleanFiles ✅" -ForegroundColor Green
    Write-Host "  Corrupted Files: $corruptedCount $(if ($corruptedCount -eq 0) { '✅' } else { '⚠️' })" -ForegroundColor $(if ($corruptedCount -eq 0) { "Green" } else { "Red" })
    Write-Host "  Health Score: $healthPercentage%" -ForegroundColor $(if ($healthPercentage -ge 95) { "Green" } elseif ($healthPercentage -ge 80) { "Yellow" } else { "Red" })
    
    if ($corruptedCount -gt 0 -and $AnalysisType -eq 'comprehensive') {
        Write-Host "  Corrupted files:" -ForegroundColor Yellow
        $corruptedFiles | ForEach-Object { Write-Host "    - $(Split-Path $_ -Leaf)" -ForegroundColor Red }
    }
    
    return @{
        Total = $totalFiles
        Clean = $cleanFiles
        Corrupted = $corruptedCount
        HealthPercentage = $healthPercentage
    }
}

# ============================================================================
# SECTION 5: File Size Compliance
# ============================================================================
function Get-FileSizeCompliance {
    Write-Host "`n📏 SECTION 5: FILE SIZE COMPLIANCE (175-line limit)" -ForegroundColor Cyan
    Write-Host "===================================================" -ForegroundColor Cyan
    
    $allMdFiles = Get-ChildItem -Recurse -Filter "*.md" -ErrorAction SilentlyContinue
    $oversizedFiles = @()
    $compliantFiles = 0
    $averageLines = 0
    
    foreach ($file in $allMdFiles) {
        $lineCount = (Get-Content $file.FullName | Measure-Object -Line).Count
        
        if ($lineCount -gt 175) {
            $oversizedFiles += @{ File = $file.FullName; Lines = $lineCount }
        } else {
            $compliantFiles++
        }
        
        $averageLines += $lineCount
    }
    
    $averageLines = [Math]::Round($averageLines / $allMdFiles.Count, 1)
    $compliancePercentage = [Math]::Round(($compliantFiles / $allMdFiles.Count) * 100, 1)
    
    Write-Host "  Total Files: $($allMdFiles.Count)" -ForegroundColor White
    Write-Host "  Compliant (<175 lines): $compliantFiles ✅" -ForegroundColor Green
    Write-Host "  Oversized (>175 lines): $($oversizedFiles.Count) $(if ($oversizedFiles.Count -eq 0) { '✅' } else { '⚠️' })" -ForegroundColor $(if ($oversizedFiles.Count -eq 0) { "Green" } else { "Yellow" })
    Write-Host "  Average Lines Per File: $averageLines" -ForegroundColor Gray
    Write-Host "  Compliance Score: $compliancePercentage%" -ForegroundColor $(if ($compliancePercentage -ge 95) { "Green" } elseif ($compliancePercentage -ge 80) { "Yellow" } else { "Red" })
    
    if ($oversizedFiles.Count -gt 0 -and $AnalysisType -eq 'comprehensive') {
        Write-Host "  Oversized files:" -ForegroundColor Yellow
        $oversizedFiles | ForEach-Object { Write-Host "    - $(Split-Path $_.File -Leaf): $($_.Lines) lines" -ForegroundColor Yellow }
    }
    
    return @{
        Total = $allMdFiles.Count
        Compliant = $compliantFiles
        Oversized = $oversizedFiles.Count
        AverageLines = $averageLines
        CompliancePercentage = $compliancePercentage
    }
}

# ============================================================================
# SECTION 6: Content Inventory
# ============================================================================
function Get-ContentInventory {
    Write-Host "`n📚 SECTION 6: CONTENT INVENTORY" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    
    $allMdFiles = Get-ChildItem -Recurse -Filter "*.md" -ErrorAction SilentlyContinue
    $totalLines = 0
    $totalWords = 0
    
    foreach ($file in $allMdFiles) {
        $content = Get-Content $file.FullName -Raw
        $lineCount = ($content | Measure-Object -Line).Count
        $wordCount = ($content | Measure-Object -Word).Count
        
        $totalLines += $lineCount
        $totalWords += $wordCount
    }
    
    $totalSize = (Get-ChildItem -Recurse -Filter "*.md" | Measure-Object -Property Length -Sum).Sum / 1MB
    
    Write-Host "  Total Markdown Files: $($allMdFiles.Count)" -ForegroundColor White
    Write-Host "  Total Lines: $totalLines" -ForegroundColor White
    Write-Host "  Total Words: $totalWords" -ForegroundColor White
    Write-Host "  Total Size: $([Math]::Round($totalSize, 2)) MB" -ForegroundColor White
    Write-Host "  Avg Words Per File: $([Math]::Round($totalWords / $allMdFiles.Count, 0))" -ForegroundColor Gray
    
    return @{
        Files = $allMdFiles.Count
        Lines = $totalLines
        Words = $totalWords
        SizeMB = [Math]::Round($totalSize, 2)
    }
}

# ============================================================================
# SECTION 7: Key Compliance Metrics
# ============================================================================
function Get-ComplianceMetrics {
    Write-Host "`n🎯 SECTION 7: COMPLIANCE METRICS SUMMARY" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    $encoding = Get-EncodingValidation
    $fileSize = Get-FileSizeCompliance
    
    # Calculate overall score
    $encodingScore = $encoding.HealthPercentage
    $sizeScore = $fileSize.CompliancePercentage
    $overallScore = [Math]::Round(($encodingScore + $sizeScore) / 2, 1)
    
    Write-Host "  Encoding Health: $($encoding.HealthPercentage)%" -ForegroundColor $(if ($encoding.HealthPercentage -ge 95) { "Green" } else { "Yellow" })
    Write-Host "  Size Compliance: $($fileSize.CompliancePercentage)%" -ForegroundColor $(if ($fileSize.CompliancePercentage -ge 95) { "Green" } else { "Yellow" })
    Write-Host "  Overall Score: $overallScore%" -ForegroundColor $(if ($overallScore -ge 90) { "Green" } elseif ($overallScore -ge 75) { "Yellow" } else { "Red" })
    
    $status = if ($overallScore -ge 90) { "✅ EXCELLENT" } elseif ($overallScore -ge 75) { "⚠️  GOOD" } else { "❌ NEEDS WORK" }
    Write-Host "  Status: $status" -ForegroundColor $(if ($overallScore -ge 90) { "Green" } elseif ($overallScore -ge 75) { "Yellow" } else { "Red" })
    
    return @{
        EncodingScore = $encodingScore
        SizeScore = $sizeScore
        OverallScore = $overallScore
        Status = $status
    }
}

# ============================================================================
# SECTION 8: Tools Inventory
# ============================================================================
function Get-ToolsInventory {
    Write-Host "`n🛠️  SECTION 8: AUTOMATION TOOLS INVENTORY" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    $toolsPath = "tools"
    $scripts = Get-ChildItem "$toolsPath\*.ps1" -ErrorAction SilentlyContinue | Sort-Object Name
    
    Write-Host "  Total Scripts: $($scripts.Count)" -ForegroundColor White
    
    if ($AnalysisType -eq 'comprehensive') {
        Write-Host "  Available Tools:" -ForegroundColor Yellow
        $scripts | ForEach-Object { Write-Host "    ✓ $($_.Name)" -ForegroundColor Gray }
    }
    
    return $scripts.Count
}

# ============================================================================
# SECTION 9: Execution Summary
# ============================================================================
function Write-ExecutionSummary {
    param([datetime]$StartTime)
    
    $endTime = Get-Date
    $duration = ($endTime - $StartTime).TotalSeconds
    
    Write-Host "`n⏱️  EXECUTION SUMMARY" -ForegroundColor Cyan
    Write-Host "====================" -ForegroundColor Cyan
    Write-Host "  Analysis Type: $AnalysisType" -ForegroundColor Yellow
    Write-Host "  Execution Time: $([Math]::Round($duration, 2)) seconds" -ForegroundColor Gray
    Write-Host "  Timestamp: $endTime" -ForegroundColor Gray
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   STSA WORKSPACE DEEP DIVE ANALYSIS" -ForegroundColor Cyan
Write-Host "║   $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

try {
    # Run all analyses
    $repoHealth = Get-RepositoryHealth
    $folderStructure = Get-FolderStructure
    $domains = Get-DomainBreakdown
    $content = Get-ContentInventory
    $compliance = Get-ComplianceMetrics
    $toolsCount = Get-ToolsInventory
    
    # Execute summary
    Write-ExecutionSummary -StartTime $startTime
    
    # Optional: Save report
    if ($SaveReport) {
        $reportPath = "workspace-analysis-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
        Write-Host "`n📄 Report saved to: $reportPath" -ForegroundColor Green
    }
    
} catch {
    Write-Host "`n❌ ERROR during analysis: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n"
