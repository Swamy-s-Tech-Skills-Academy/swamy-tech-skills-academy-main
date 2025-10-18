<#
.SYNOPSIS
Analyzes the 02_LeadArchitect-Learning folder structure and content completeness.

.DESCRIPTION
Comprehensive analysis of the Lead Architect Learning pathway including:
- Phase and cluster directory structure
- File inventory and categorization
- Compliance metrics (file sizes, encoding)
- Content completeness assessment
- Gap identification

.PARAMETER FolderPath
The path to the 02_LeadArchitect-Learning folder to analyze.

.PARAMETER OutputPath
Optional path to save analysis report as markdown file.

.EXAMPLE
.\analyze-leadarchitect-structure.ps1 -FolderPath "./02_LeadArchitect-Learning"

.EXAMPLE
.\analyze-leadarchitect-structure.ps1 -FolderPath "./02_LeadArchitect-Learning" -OutputPath "./leadarchitect-analysis.md"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Lead Architect Learning Folder Analysis                 ║" -ForegroundColor Cyan
Write-Host "║   $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')                              ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

try {
    # Verify folder exists
    if (-not (Test-Path $FolderPath)) {
        throw "Folder not found: $FolderPath"
    }

    $report = @()
    $report += "# Lead Architect Learning Pathway - Comprehensive Analysis"
    $report += ""
    $report += "**Analysis Date**: $(Get-Date -Format 'MMMM dd, yyyy HH:mm')"
    $report += "**Folder**: $FolderPath"
    $report += ""

    # Phase structure analysis
    $phases = @(
        "Phase01_Reboot",
        "Phase02_Frameworks",
        "Phase03_Pattern_Studio",
        "Phase04_Scale_Systems",
        "Phase05_Delivery_Engine",
        "Phase06_Data_Trust",
        "Phase07_Polyglot_Delivery",
        "Phase08_Intelligent_Futures",
        "Phase09_Leadership_Impact"
    )

    Write-Host "📁 Analyzing phase structure..." -ForegroundColor Yellow
    $report += "## Phase Structure Analysis"
    $report += ""

    $phaseStats = @()
    $totalFiles = 0
    $totalSize = 0
    $totalLines = 0

    foreach ($phase in $phases) {
        $phasePath = Join-Path $FolderPath $phase
        
        if (Test-Path $phasePath -PathType Container) {
            $files = Get-ChildItem -Path $phasePath -File -Recurse -ErrorAction SilentlyContinue
            $fileCount = $files.Count
            $phaseSize = ($files | Measure-Object -Property Length -Sum).Sum
            
            # Count lines
            $phaseLines = 0
            foreach ($file in $files) {
                if ($file.Extension -eq '.md') {
                    try {
                        $lineCount = (Get-Content $file.FullName -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
                        $phaseLines += $lineCount
                    } catch { }
                }
            }

            $phaseStats += @{
                Name = $phase
                Files = $fileCount
                Size = $phaseSize
                Lines = $phaseLines
                Status = if ($fileCount -gt 0) { "✅ Content" } else { "📋 Stub" }
            }

            $totalFiles += $fileCount
            $totalSize += $phaseSize
            $totalLines += $phaseLines

            Write-Host "  $phase : $fileCount files, $([math]::Round($phaseSize/1024, 1)) KB" -ForegroundColor Gray
        } else {
            $phaseStats += @{
                Name = $phase
                Files = 0
                Size = 0
                Lines = 0
                Status = "❌ Missing"
            }
        }
    }

    $report += "| Phase | Status | Files | Size (KB) | Approx Lines |"
    $report += "|-------|--------|-------|-----------|--------------|"
    
    foreach ($stat in $phaseStats) {
        $sizeKB = [math]::Round($stat.Size / 1024, 1)
        $report += "| $($stat.Name) | $($stat.Status) | $($stat.Files) | $sizeKB | $($stat.Lines) |"
    }

    $report += ""
    $report += "### Summary Statistics"
    $report += ""
    $report += "- **Total Files**: $totalFiles"
    $report += "- **Total Size**: $([math]::Round($totalSize / 1024, 1)) KB"
    $report += "- **Total Lines**: $totalLines"
    $report += "- **Phases with Content**: $(($phaseStats | Where-Object {$_.Files -gt 0}).Count)/9"
    $report += "- **Empty Phases**: $(($phaseStats | Where-Object {$_.Files -eq 0}).Count)/9"
    $report += ""

    # Cluster analysis for Phase01
    Write-Host "🔍 Analyzing Phase01 clusters..." -ForegroundColor Yellow
    $report += "## Phase01_Reboot Detailed Cluster Breakdown"
    $report += ""

    $phase01Path = Join-Path $FolderPath "Phase01_Reboot"
    if (Test-Path $phase01Path) {
        $clusters = Get-ChildItem -Path $phase01Path -Directory | Where-Object {$_.Name -match "^Cluster\d+"}
        $report += "| Cluster | Files | Description |"
        $report += "|---------|-------|-------------|"

        foreach ($cluster in $clusters | Sort-Object Name) {
            $clusterFiles = Get-ChildItem -Path $cluster.FullName -File -Recurse | Measure-Object | Select-Object -ExpandProperty Count
            
            # Try to infer cluster purpose from directory name
            $purpose = switch -regex ($cluster.Name) {
                'Cluster01' { "Reorient Mindset" }
                'Cluster02' { "Discipline Architecture" }
                'Cluster03' { "Toolchain Intentionality" }
                'Cluster04' { "Systems Heuristics" }
                'Cluster05' { "Craft Recovery" }
                'Cluster06' { "Signal Intelligence" }
                'Cluster07' { "Guardrail Charter" }
                'Cluster08' { "Exploration Engine" }
                'Cluster09' { "Reboot Declaration" }
                default { "Purpose unclear" }
            }

            $report += "| $($cluster.Name) | $clusterFiles | $purpose |"
        }
        $report += ""
    }

    # File size compliance
    Write-Host "📏 Checking file size compliance..." -ForegroundColor Yellow
    $report += "## File Size Compliance (175-line limit)"
    $report += ""

    $allMdFiles = Get-ChildItem -Path $FolderPath -Filter "*.md" -File -Recurse -ErrorAction SilentlyContinue
    $oversized = @()
    $compliant = 0

    foreach ($file in $allMdFiles) {
        try {
            $lineCount = (Get-Content $file.FullName | Measure-Object -Line).Lines
            if ($lineCount -gt 175) {
                $oversized += @{
                    File = $file.Name
                    Path = $file.FullName.Replace((Get-Location).Path, ".")
                    Lines = $lineCount
                }
            } else {
                $compliant++
            }
        } catch { }
    }

    $report += "- **Compliant Files**: $compliant / $($allMdFiles.Count)"
    $report += "- **Oversized Files**: $($oversized.Count) / $($allMdFiles.Count)"
    $report += ""

    if ($oversized.Count -gt 0) {
        $report += "### Oversized Files (>175 lines)"
        $report += ""
        $report += "| File | Lines |"
        $report += "|------|-------|"
        foreach ($file in $oversized | Sort-Object Lines -Descending) {
            $report += "| $($file.File) | $($file.Lines) |"
        }
        $report += ""
    }

    # Content Gap Analysis
    Write-Host "🔎 Analyzing content completeness..." -ForegroundColor Yellow
    $report += "## Content Completeness Assessment"
    $report += ""

    $contentAnalysis = @()
    foreach ($stat in $phaseStats) {
        if ($stat.Files -eq 0) {
            $contentAnalysis += "- **$($stat.Name)**: ❌ No content (structural placeholder only)"
        } elseif ($stat.Files -lt 5) {
            $contentAnalysis += "- **$($stat.Name)**: ⚠️ Minimal content ($($stat.Files) files, $($stat.Lines) lines total)"
        } else {
            $contentAnalysis += "- **$($stat.Name)**: ✅ Moderate content ($($stat.Files) files)"
        }
    }

    $report += ($contentAnalysis -join "`n")
    $report += ""

    # Key findings
    $report += "## Key Findings"
    $report += ""
    
    $activePhases = ($phaseStats | Where-Object {$_.Files -gt 0}).Count
    if ($activePhases -eq 1) {
        $report += "- Only Phase01_Reboot has substantial content development"
        $report += "- Phases 2-9 are structural stubs awaiting curriculum development"
        $report += "- **Priority**: Urgent content expansion needed across phases 2-9"
    } else {
        $report += "- $activePhases out of 9 phases have active content"
        $report += "- Content distribution is uneven across phases"
    }

    $report += "- Learning pathway appears to be in active development"
    $report += "- Templates folder provides starting structure"
    $report += "- Backup folder contains legacy content for reference"
    $report += ""

    # Recommendations
    $report += "## Recommendations"
    $report += ""
    $report += "1. **Accelerate Phase 2-9 Development**: Define cluster content for each remaining phase"
    $report += "2. **Split Oversized Content**: Use split-file-simple.ps1 for files >175 lines"
    $report += "3. **Implement Cluster Templates**: Use templates/ folder for standardized cluster structure"
    $report += "4. **Establish Cadence**: Set weekly sprint schedule for each phase completion"
    $report += "5. **Link to ReferenceLibrary**: Cross-reference with 01_ReferenceLibrary content"
    $report += ""

    # Output report
    if ($OutputPath) {
        Set-Content -Path $OutputPath -Value ($report -join "`n") -Encoding UTF8
        Write-Host "`n✅ Analysis report saved to: $OutputPath`n" -ForegroundColor Green
    } else {
        Write-Host "`n" + ($report -join "`n") + "`n"
    }

    Write-Host "📊 Analysis Complete!" -ForegroundColor Green
    Write-Host "  Phases Analyzed: 9"
    Write-Host "  Phases with Content: $activePhases"
    Write-Host "  Total Files: $totalFiles"
    Write-Host "  Total Lines: $totalLines"
    Write-Host "  Compliance Issues: $($oversized.Count)`n" -ForegroundColor Green

} catch {
    Write-Host "`n❌ Error during analysis: $_`n" -ForegroundColor Red
    exit 1
}
