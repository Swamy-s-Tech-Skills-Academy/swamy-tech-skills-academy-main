# File Analysis Tool for STSA Repository
# Usage: .\file-analysis.ps1 -Path "relative\path\to\folder"
# Example: .\file-analysis.ps1 -Path "01_ReferenceLibrary\01_Development\01_software-design-principles\01_OOP-Fundamentals"

param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    
    [Parameter(Mandatory = $false)]
    [string]$Filter = "*.md",
    
    [Parameter(Mandatory = $false)]
    [switch]$IncludeContent = $false,
    
    [Parameter(Mandatory = $false)]
    [int]$LineLimit = 175
)

# Get the repository root (assumes script is in tools folder)
$repoRoot = Split-Path $PSScriptRoot -Parent
$fullPath = Join-Path $repoRoot $Path

Write-Host "🔍 STSA File Analysis Tool" -ForegroundColor Cyan
Write-Host "Analyzing: $fullPath" -ForegroundColor Yellow
Write-Host "Filter: $Filter" -ForegroundColor Gray
Write-Host ""

if (-not (Test-Path $fullPath)) {
    Write-Host "❌ Path not found: $fullPath" -ForegroundColor Red
    exit 1
}

# Get all files matching filter
$files = Get-ChildItem $fullPath -Filter $Filter | Sort-Object Name

if ($files.Count -eq 0) {
    Write-Host "⚠️ No files found matching filter: $Filter" -ForegroundColor Yellow
    exit 0
}

Write-Host "📊 FILE ANALYSIS RESULTS" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

# Create analysis table
$analysis = @()
foreach ($file in $files) {
    $content = Get-Content $file.FullName -ErrorAction SilentlyContinue
    $lineCount = ($content | Measure-Object -Line).Lines
    $sizeKB = [math]::Round($file.Length / 1KB, 1)
    
    # Check for common issues
    $issues = @()
    if ($lineCount -gt $LineLimit) {
        $issues += "⚠️ Over $LineLimit lines"
    }
    if ($content -match "�") {
        $issues += "❌ Encoding issues (�)"
    }
    if ($content -match "```\s*$") {
        $issues += "⚠️ Missing code block language"
    }
    
    $status = if ($issues.Count -eq 0) { "✅ Good" } else { "⚠️ Issues" }
    
    $analysis += [PSCustomObject]@{
        File       = $file.Name
        Lines      = $lineCount
        'Size(KB)' = $sizeKB
        Status     = $status
        Issues     = if ($issues) { $issues -join "; " } else { "None" }
    }
}

# Display results
$analysis | Format-Table -AutoSize -Wrap

# Summary statistics
$totalFiles = $analysis.Count
$goodFiles = ($analysis | Where-Object { $_.Status -eq "✅ Good" }).Count
$issueFiles = $totalFiles - $goodFiles
$totalLines = ($analysis | Measure-Object -Property Lines -Sum).Sum
$avgLines = [math]::Round($totalLines / $totalFiles, 0)

Write-Host ""
Write-Host "📈 SUMMARY STATISTICS" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "Total Files: $totalFiles" -ForegroundColor White
Write-Host "Good Files: $goodFiles" -ForegroundColor Green
Write-Host "Files with Issues: $issueFiles" -ForegroundColor $(if ($issueFiles -gt 0) { 'Red' }else { 'Green' })
Write-Host "Total Lines: $totalLines" -ForegroundColor White
Write-Host "Average Lines/File: $avgLines" -ForegroundColor White
Write-Host "Line Limit Guideline: $LineLimit lines (27-minute focused sessions)" -ForegroundColor Gray

# Show content preview if requested
if ($IncludeContent) {
    Write-Host ""
    Write-Host "📝 CONTENT PREVIEW" -ForegroundColor Cyan
    Write-Host "=================" -ForegroundColor Cyan
    
    foreach ($file in $files) {
        Write-Host ""
        Write-Host "📄 $($file.Name)" -ForegroundColor Yellow
        Write-Host "$(Get-Content $file.FullName | Select-Object -First 5)" -ForegroundColor Gray
        Write-Host "..." -ForegroundColor DarkGray
    }
}

# Quality recommendations
Write-Host ""
Write-Host "🎯 QUALITY RECOMMENDATIONS" -ForegroundColor Magenta
Write-Host "=========================" -ForegroundColor Magenta

if ($issueFiles -eq 0) {
    Write-Host "✅ All files meet quality standards!" -ForegroundColor Green
}
else {
    Write-Host "Consider fixing files with issues:" -ForegroundColor Yellow
    $analysis | Where-Object { $_.Status -ne "✅ Good" } | ForEach-Object {
        Write-Host "  • $($_.File): $($_.Issues)" -ForegroundColor Yellow
    }
}

if ($avgLines -gt $LineLimit) {
    Write-Host "💡 Average lines ($avgLines) exceeds guideline ($LineLimit)" -ForegroundColor Yellow
    Write-Host "   Consider splitting longer files into Parts A, B, C..." -ForegroundColor Gray
}

Write-Host ""
Write-Host "🔧 USAGE TIPS" -ForegroundColor Blue
Write-Host "============" -ForegroundColor Blue
Write-Host "• Add -IncludeContent for content preview" -ForegroundColor Gray
Write-Host "• Change -LineLimit to adjust warning threshold" -ForegroundColor Gray
Write-Host "• Use -Filter '*.txt' for different file types" -ForegroundColor Gray
