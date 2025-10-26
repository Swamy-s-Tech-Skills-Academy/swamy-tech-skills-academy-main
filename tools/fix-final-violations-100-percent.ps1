# Final Round: Fix Last 14 Violations in SOLID-Principles
# Target: MD012 (multiple blanks at file end) and MD038 (space in code spans)

param(
    [Parameter(Mandatory=$false)]
    [string]$FolderPath = "01_ReferenceLibrary\01_Development\01_software-design-principles\02_SOLID-Principles"
)

$ErrorActionPreference = "Stop"

Write-Host "🎯 FINAL ROUND: Fixing last 14 violations for 100% A+" -ForegroundColor Yellow

# Get all markdown files
$files = Get-ChildItem $FolderPath -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }

$totalFixed = 0

foreach ($file in $files) {
    Write-Host "🔧 Processing: $($file.Name)" -ForegroundColor Cyan
    
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fileFixed = 0
    
    # Fix MD038: Spaces inside code span elements "`byte[] `"
    $md038Fixed = 0
    $pattern = '`([^`]*)\s+`'
    $matches = [regex]::Matches($content, $pattern)
    
    foreach ($match in $matches) {
        # Only fix if it's the problematic "`byte[] `" pattern
        if ($match.Value -match '`[^`]*\s+`') {
            $oldValue = $match.Value
            $newValue = $match.Value -replace '\s+`$', '`'
            $content = $content -replace [regex]::Escape($oldValue), $newValue
            $md038Fixed++
            Write-Host "    Fixed MD038: '$oldValue' -> '$newValue'" -ForegroundColor Green
        }
    }
    
    if ($md038Fixed -gt 0) {
        Write-Host "  ✅ Fixed $md038Fixed MD038 code span spaces" -ForegroundColor Green
        $fileFixed += $md038Fixed
    }
    
    # Fix MD012: Multiple consecutive blank lines at end of files
    $md012Fixed = 0
    
    # Check lines around 169-173 specifically
    $lines = $content -split "`r?`n"
    $fixedLines = @()
    $endBlankCount = 0
    
    # Process lines and count trailing blanks
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # If we're near the end, check for blank line patterns
        if ($i -ge ($lines.Count - 10)) {
            if ([string]::IsNullOrWhiteSpace($line)) {
                $endBlankCount++
            } else {
                $endBlankCount = 0
            }
            
            # If we have 2+ consecutive blanks, only keep 1
            if ($endBlankCount -le 1) {
                $fixedLines += $line
            } else {
                $md012Fixed++
            }
        } else {
            $fixedLines += $line
        }
    }
    
    # Also fix any multiple blanks within content
    $contentWithFixed = $fixedLines -join "`n"
    while ($contentWithFixed -match "`n`n`n+") {
        $contentWithFixed = $contentWithFixed -replace "`n`n`n+", "`n`n"
        $md012Fixed++
    }
    
    if ($md012Fixed -gt 0) {
        $content = $contentWithFixed
        Write-Host "  ✅ Fixed $md012Fixed MD012 multiple blank lines" -ForegroundColor Green
        $fileFixed += $md012Fixed
    }
    
    # Write back to file if changes were made
    if ($content -ne $originalContent) {
        $content | Set-Content $file.FullName -NoNewline
        Write-Host "  💾 Updated $($file.Name)" -ForegroundColor Green
        $totalFixed += $fileFixed
    } else {
        Write-Host "  ✨ $($file.Name) already clean" -ForegroundColor Gray
    }
}

Write-Host "`n🎉 FINAL ROUND SUMMARY:" -ForegroundColor Yellow
Write-Host "📁 Files processed: $($files.Count)" -ForegroundColor Cyan
Write-Host "🔧 Final violations fixed: $totalFixed" -ForegroundColor Green

# Ultimate verification - SOLID-Principles only
Write-Host "`n🏆 ULTIMATE VERIFICATION..." -ForegroundColor Cyan
$remainingViolations = npx markdownlint-cli2 "$FolderPath\*.md" --config .markdownlint.json 2>&1 | Where-Object { $_ -notmatch "Summary:" -and $_ -notmatch "Linting:" -and $_ -notmatch "Finding:" -and $_.Trim() -ne "" }

if ($remainingViolations) {
    $violationCount = ($remainingViolations | Measure-Object).Count
    Write-Host "⚠️ $violationCount violations remaining" -ForegroundColor Yellow
    Write-Host "Remaining violations:" -ForegroundColor Yellow
    $remainingViolations | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
} else {
    Write-Host "🏆 PERFECT! 100% A+ ACHIEVED!" -ForegroundColor Green
    Write-Host "🎉 ALL MARKDOWN VIOLATIONS ELIMINATED!" -ForegroundColor Green
}