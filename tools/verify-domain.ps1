# Quick Domain Verification Tool for STSA Repository
# Usage: .\verify-domain.ps1 -Domain "01_OOP-Fundamentals"
# Usage: .\verify-domain.ps1 (interactive mode)

param(
    [Parameter(Mandatory=$false)]
    [string]$Domain = ""
)

# Get the repository root (assumes script is in tools folder)
$repoRoot = Split-Path $PSScriptRoot -Parent
$designPrinciplesPath = Join-Path $repoRoot "01_ReferenceLibrary\01_Development\01_software-design-principles"

Write-Host "🔍 QUICK DOMAIN VERIFICATION" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""

# Interactive mode if no domain specified
if ($Domain -eq "") {
    $availableDomains = Get-ChildItem $designPrinciplesPath -Directory | Where-Object { $_.Name -match '^\d+_' } | Sort-Object Name
    
    Write-Host "📚 Available Domains:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $availableDomains.Count; $i++) {
        Write-Host "  $($i + 1). $($availableDomains[$i].Name)" -ForegroundColor White
    }
    Write-Host ""
    
    do {
        $selection = Read-Host "Select domain number (1-$($availableDomains.Count)) or 'q' to quit"
        if ($selection -eq 'q') { exit 0 }
        $index = [int]$selection - 1
    } while ($index -lt 0 -or $index -ge $availableDomains.Count)
    
    $Domain = $availableDomains[$index].Name
    Write-Host ""
}

$domainPath = Join-Path $designPrinciplesPath $Domain

if (-not (Test-Path $domainPath)) {
    Write-Host "❌ Domain not found: $Domain" -ForegroundColor Red
    exit 1
}

Write-Host "🎯 VERIFYING: $Domain" -ForegroundColor Green
Write-Host "$(('=' * ($Domain.Length + 12)))" -ForegroundColor Green
Write-Host ""

# Quick file count and analysis
$files = Get-ChildItem $domainPath -Filter "*.md" | Sort-Object Name
Write-Host "📄 Files Found: $($files.Count)" -ForegroundColor White

if ($files.Count -eq 0) {
    Write-Host "⚠️ No markdown files in domain" -ForegroundColor Yellow
    exit 0
}

# Quick verification checks
$results = @{
    ReadmeExists = Test-Path (Join-Path $domainPath "README.md")
    PartFiles = ($files | Where-Object { $_.Name -match '^0\d[A-Z]?_.*\.md$' }).Count
    OriginalFiles = ($files | Where-Object { $_.Name -match '^\d+_.*\.md$' -and $_.Name -notmatch '^0\d[A-Z]?_' }).Count
    OversizedFiles = @()
    EncodingIssues = @()
    MissingLanguage = @()
}

# Check each file quickly
foreach ($file in $files) {
    $content = Get-Content $file.FullName -ErrorAction SilentlyContinue -Raw
    $lineCount = ($content -split "`n").Count
    
    # Line count check
    if ($lineCount -gt 175) {
        $results.OversizedFiles += "$($file.Name) ($lineCount lines)"
    }
    
    # Encoding check
    if ($content -match "�") {
        $results.EncodingIssues += $file.Name
    }
    
    # Code block language check
    if ($content -match "```\s*\r?\n") {
        $results.MissingLanguage += $file.Name
    }
}

# Display results
Write-Host "✅ VERIFICATION RESULTS" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green

Write-Host "📋 README.md: $(if($results.ReadmeExists){'✅ Present'}else{'❌ Missing'})" -ForegroundColor $(if($results.ReadmeExists){'Green'}else{'Red'})
Write-Host "📝 Part Files (New Format): $($results.PartFiles)" -ForegroundColor $(if($results.PartFiles -gt 0){'Green'}else{'Yellow'})
Write-Host "📚 Original Files: $($results.OriginalFiles)" -ForegroundColor $(if($results.OriginalFiles -eq 0){'Green'}else{'Yellow'})

# Issues section
$hasIssues = $false

if ($results.OversizedFiles.Count -gt 0) {
    $hasIssues = $true
    Write-Host ""
    Write-Host "⚠️ OVERSIZED FILES (>175 lines):" -ForegroundColor Yellow
    $results.OversizedFiles | ForEach-Object { Write-Host "  • $_" -ForegroundColor Yellow }
}

if ($results.EncodingIssues.Count -gt 0) {
    $hasIssues = $true
    Write-Host ""
    Write-Host "❌ ENCODING ISSUES (� character):" -ForegroundColor Red
    $results.EncodingIssues | ForEach-Object { Write-Host "  • $_" -ForegroundColor Red }
}

if ($results.MissingLanguage.Count -gt 0) {
    $hasIssues = $true
    Write-Host ""
    Write-Host "⚠️ CODE BLOCKS WITHOUT LANGUAGE:" -ForegroundColor Yellow
    $results.MissingLanguage | ForEach-Object { Write-Host "  • $_" -ForegroundColor Yellow }
}

# Overall status
Write-Host ""
if (-not $hasIssues -and $results.ReadmeExists -and $results.PartFiles -gt 0) {
    Write-Host "🎉 DOMAIN STATUS: EXCELLENT" -ForegroundColor Green
    Write-Host "All files meet STSA quality standards!" -ForegroundColor Green
} elseif (-not $hasIssues -and $results.ReadmeExists) {
    Write-Host "✅ DOMAIN STATUS: GOOD" -ForegroundColor Green
    Write-Host "No critical issues detected." -ForegroundColor Green
} else {
    Write-Host "⚠️ DOMAIN STATUS: NEEDS ATTENTION" -ForegroundColor Yellow
    Write-Host "Consider addressing the issues above." -ForegroundColor Yellow
}

# Quick recommendations
Write-Host ""
Write-Host "💡 QUICK ACTIONS" -ForegroundColor Blue
Write-Host "===============" -ForegroundColor Blue

if (-not $results.ReadmeExists) {
    Write-Host "• Create README.md for domain overview" -ForegroundColor Gray
}

if ($results.PartFiles -eq 0 -and $results.OriginalFiles -gt 0) {
    Write-Host "• Consider restructuring into 30-minute parts (Parts A, B, C...)" -ForegroundColor Gray
}

if ($results.OversizedFiles.Count -gt 0) {
    Write-Host "• Split large files into smaller 150-175 line segments" -ForegroundColor Gray
}

if ($results.EncodingIssues.Count -gt 0) {
    Write-Host "• Fix encoding issues (replace � characters)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🔧 ADVANCED ANALYSIS" -ForegroundColor Magenta
Write-Host "Use: .\file-analysis.ps1 -Path '$Domain' for detailed analysis" -ForegroundColor Gray
Write-Host "Use: .\daily-progress.ps1 -Domain '$Domain' -ShowDetails for content review" -ForegroundColor Gray
