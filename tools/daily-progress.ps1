# Daily Learning Progress Tracker for STSA Repository
# Usage: .\daily-progress.ps1 -Domain "01_OOP-Fundamentals"
# Example: .\daily-progress.ps1 -Domain "01_OOP-Fundamentals" -ShowDetails

param(
    [Parameter(Mandatory = $false)]
    [string]$Domain = "",
    
    [Parameter(Mandatory = $false)]
    [switch]$ShowDetails = $false,
    
    [Parameter(Mandatory = $false)]
    [switch]$AllDomains = $false
)

# Get the repository root (assumes script is in tools folder)
$repoRoot = Split-Path $PSScriptRoot -Parent
$designPrinciplesPath = Join-Path $repoRoot "01_ReferenceLibrary\01_Development\01_software-design-principles"

Write-Host "📊 DAILY LEARNING PROGRESS TRACKER" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd')" -ForegroundColor Yellow
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $designPrinciplesPath)) {
    Write-Host "❌ Software design principles path not found" -ForegroundColor Red
    exit 1
}

# Get all domains
$domains = Get-ChildItem $designPrinciplesPath -Directory | Where-Object { $_.Name -match '^\d+_' } | Sort-Object Name

if ($AllDomains -or $Domain -eq "") {
    Write-Host "🎯 ALL DOMAINS OVERVIEW" -ForegroundColor Green
    Write-Host "=======================" -ForegroundColor Green
    Write-Host ""
    
    $domainProgress = @()
    foreach ($domainDir in $domains) {
        $files = Get-ChildItem $domainDir.FullName -Filter "*.md" -Exclude "README.md"
        $readmeExists = Test-Path (Join-Path $domainDir.FullName "README.md")
        
        # Count different types of files
        $partFiles = $files | Where-Object { $_.Name -match '^0\d[A-Z]?_.*\.md$' }
        $originalFiles = $files | Where-Object { $_.Name -match '^\d+_.*(?<!Part\d)\.md$' -and $_.Name -notmatch '^0\d[A-Z]?_' }
        
        $status = if ($partFiles.Count -gt 0) { "✅ Restructured" } 
        elseif ($files.Count -gt 1) { "🔄 In Progress" } 
        else { "📋 Planned" }
        
        $domainProgress += [PSCustomObject]@{
            Domain           = $domainDir.Name
            'README'         = if ($readmeExists) { "✅" } else { "❌" }
            'Part Files'     = $partFiles.Count
            'Original Files' = $originalFiles.Count
            'Total Files'    = $files.Count
            Status           = $status
        }
    }
    
    $domainProgress | Format-Table -AutoSize
    
    # Summary stats
    $totalDomains = $domainProgress.Count
    $restructuredDomains = ($domainProgress | Where-Object { $_.Status -eq "✅ Restructured" }).Count
    $inProgressDomains = ($domainProgress | Where-Object { $_.Status -eq "🔄 In Progress" }).Count
    $plannedDomains = ($domainProgress | Where-Object { $_.Status -eq "📋 Planned" }).Count
    
    Write-Host ""
    Write-Host "📈 PROGRESS SUMMARY" -ForegroundColor Magenta
    Write-Host "==================" -ForegroundColor Magenta
    Write-Host "Total Domains: $totalDomains" -ForegroundColor White
    Write-Host "Restructured (200-line format): $restructuredDomains" -ForegroundColor Green
    Write-Host "In Progress: $inProgressDomains" -ForegroundColor Yellow
    Write-Host "Planned: $plannedDomains" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Completion: $([math]::Round(($restructuredDomains / $totalDomains) * 100, 1))%" -ForegroundColor $(if ($restructuredDomains -gt $inProgressDomains) { 'Green' }else { 'Yellow' })
}

# Specific domain analysis
if ($Domain -ne "" -and -not $AllDomains) {
    $domainPath = Join-Path $designPrinciplesPath $Domain
    
    if (-not (Test-Path $domainPath)) {
        Write-Host "❌ Domain not found: $Domain" -ForegroundColor Red
        Write-Host "Available domains:" -ForegroundColor Yellow
        $domains | ForEach-Object { Write-Host "  • $($_.Name)" -ForegroundColor Gray }
        exit 1
    }
    
    Write-Host "🎯 DOMAIN ANALYSIS: $Domain" -ForegroundColor Green
    Write-Host "$(('=' * ($Domain.Length + 18)))" -ForegroundColor Green
    Write-Host ""
    
    $files = Get-ChildItem $domainPath -Filter "*.md" | Sort-Object Name
    
    if ($files.Count -eq 0) {
        Write-Host "⚠️ No markdown files found in domain" -ForegroundColor Yellow
        exit 0
    }
    
    # Analyze file structure
    $fileAnalysis = @()
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -ErrorAction SilentlyContinue
        $lineCount = ($content | Measure-Object -Line).Lines
        
        # Determine file type and status
        $fileType = if ($file.Name -eq "README.md") { "📋 README" }
        elseif ($file.Name -match '^0\d[A-Z]_.*\.md$') { "✅ Part (New)" }
        elseif ($file.Name -match '^\d+_.*\.md$') { "📚 Original" }
        else { "❓ Other" }
        
        $compliance = if ($lineCount -le 200) { "✅" } elseif ($lineCount -le 300) { "⚠️" } else { "❌" }
        
        $fileAnalysis += [PSCustomObject]@{
            File              = $file.Name
            Type              = $fileType
            Lines             = $lineCount
            'Size Compliance' = $compliance
            'Last Modified'   = $file.LastWriteTime.ToString('MM-dd HH:mm')
        }
    }
    
    $fileAnalysis | Format-Table -AutoSize -Wrap
    
    if ($ShowDetails) {
        Write-Host ""
        Write-Host "📝 DETAILED CONTENT ANALYSIS" -ForegroundColor Blue
        Write-Host "============================" -ForegroundColor Blue
        
        foreach ($file in $files) {
            Write-Host ""
            Write-Host "📄 $($file.Name)" -ForegroundColor Yellow
            
            $content = Get-Content $file.FullName -ErrorAction SilentlyContinue
            $firstLines = $content | Select-Object -First 10
            
            # Look for learning objectives
            $hasObjectives = $content -match "Learning Objectives|🎯"
            $hasMermaid = $content -match "```mermaid"
            $hasPseudocode = $content -match "```text"
            $hasTimeEstimate = $content -match "30 minutes|Estimated Time"
            
            Write-Host "Features:" -ForegroundColor Gray
            Write-Host "  Learning Objectives: $(if($hasObjectives){'✅'}else{'❌'})" -ForegroundColor Gray
            Write-Host "  Mermaid Diagrams: $(if($hasMermaid){'✅'}else{'❌'})" -ForegroundColor Gray
            Write-Host "  Pseudocode: $(if($hasPseudocode){'✅'}else{'❌'})" -ForegroundColor Gray
            Write-Host "  Time Estimate: $(if($hasTimeEstimate){'✅'}else{'❌'})" -ForegroundColor Gray
            
            Write-Host "Preview:" -ForegroundColor Gray
            $firstLines | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
        }
    }
    
    # Domain recommendations
    Write-Host ""
    Write-Host "💡 RECOMMENDATIONS" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    
    $partFiles = $fileAnalysis | Where-Object { $_.Type -eq "✅ Part (New)" }
    $originalFiles = $fileAnalysis | Where-Object { $_.Type -eq "📚 Original" }
    $oversizedFiles = $fileAnalysis | Where-Object { $_.Lines -gt 200 }
    
    if ($partFiles.Count -eq 0 -and $originalFiles.Count -gt 0) {
        Write-Host "🔄 Domain ready for restructuring into 30-minute parts" -ForegroundColor Yellow
    }
    elseif ($partFiles.Count -gt 0 -and $originalFiles.Count -gt 0) {
        Write-Host "✅ Partial restructuring complete" -ForegroundColor Green
        Write-Host "📋 Consider completing restructuring of remaining original files" -ForegroundColor Yellow
    }
    elseif ($partFiles.Count -gt 0) {
        Write-Host "🎉 Domain fully restructured for optimal learning!" -ForegroundColor Green
    }
    
    if ($oversizedFiles.Count -gt 0) {
        Write-Host "⚠️ Files exceeding 300-line guideline:" -ForegroundColor Yellow
        $oversizedFiles | ForEach-Object { Write-Host "  • $($_.File) ($($_.Lines) lines)" -ForegroundColor Yellow }
    }
}

Write-Host ""
Write-Host "🎯 NEXT STEPS" -ForegroundColor Blue
Write-Host "=============" -ForegroundColor Blue
Write-Host "• Use: .\file-analysis.ps1 -Path 'domain\path' for detailed analysis" -ForegroundColor Gray
Write-Host "• Use: .\daily-progress.ps1 -Domain 'domain-name' -ShowDetails" -ForegroundColor Gray
Write-Host "• Focus on one domain per day for systematic mastery" -ForegroundColor Gray
