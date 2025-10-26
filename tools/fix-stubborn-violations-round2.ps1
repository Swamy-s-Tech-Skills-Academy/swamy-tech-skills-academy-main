# Fix Stubborn Markdown Violations - Round 2
# More targeted approach for remaining violations

param(
    [Parameter(Mandatory=$false)]
    [string]$FolderPath = "01_ReferenceLibrary\01_Development\01_software-design-principles\02_SOLID-Principles"
)

$ErrorActionPreference = "Stop"

Write-Host "🎯 Round 2: Fixing stubborn violations in SOLID-Principles" -ForegroundColor Yellow

# Get all markdown files
$files = Get-ChildItem $FolderPath -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }

$totalFixed = 0

foreach ($file in $files) {
    Write-Host "🔧 Processing: $($file.Name)" -ForegroundColor Cyan
    
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fileFixed = 0
    
    # Fix MD009: Single trailing spaces more aggressively
    $lines = $content -split "`r?`n"
    $fixedLines = @()
    $singleSpacesFixed = 0
    
    foreach ($line in $lines) {
        # Remove ALL trailing whitespace, then check if we need to preserve line breaks
        $trimmedLine = $line -replace "\s+$", ""
        
        # Check if this was intentionally a line break (ended with exactly 2 spaces)
        if ($line -match "  $") {
            # Preserve the 2-space line break
            $fixedLines += $trimmedLine + "  "
        } else {
            # Remove all trailing spaces
            if ($line -ne $trimmedLine) {
                $singleSpacesFixed++
            }
            $fixedLines += $trimmedLine
        }
    }
    
    if ($singleSpacesFixed -gt 0) {
        $content = $fixedLines -join "`n"
        Write-Host "  ✅ Fixed $singleSpacesFixed single trailing spaces" -ForegroundColor Green
        $fileFixed += $singleSpacesFixed
    }
    
    # Fix MD037: Spaces inside emphasis markers more comprehensively
    $md037Fixed = 0
    
    # Pattern 1: "word _text_" -> "word_text_"
    $pattern1Matches = [regex]::Matches($content, "(\w) _([^_\n]+)_").Count
    $content = $content -replace "(\w) _([^_\n]+)_", '$1_$2_'
    $md037Fixed += $pattern1Matches
    
    # Pattern 2: "_text _" -> "_text_"
    $pattern2Matches = [regex]::Matches($content, "_([^_\n]+) _").Count
    $content = $content -replace "_([^_\n]+) _", '_$1_'
    $md037Fixed += $pattern2Matches
    
    # Pattern 3: "` _" -> "`_"
    $pattern3Matches = [regex]::Matches($content, "` _").Count
    $content = $content -replace "` _", '`_'
    $md037Fixed += $pattern3Matches
    
    if ($md037Fixed -gt 0) {
        Write-Host "  ✅ Fixed $md037Fixed MD037 emphasis markers" -ForegroundColor Green
        $fileFixed += $md037Fixed
    }
    
    # Fix MD012: Multiple consecutive blank lines more aggressively
    $md012Fixed = 0
    
    # Replace 2+ consecutive blank lines with single blank line
    while ($content -match "`n`n`n+") {
        $content = $content -replace "`n`n`n+", "`n`n"
        $md012Fixed++
    }
    
    if ($md012Fixed -gt 0) {
        Write-Host "  ✅ Fixed $md012Fixed multiple blank line groups" -ForegroundColor Green
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

Write-Host "`n🎉 ROUND 2 SUMMARY:" -ForegroundColor Yellow
Write-Host "📁 Files processed: $($files.Count)" -ForegroundColor Cyan
Write-Host "🔧 Additional violations fixed: $totalFixed" -ForegroundColor Green

# Final verification
Write-Host "`n🔍 Final verification..." -ForegroundColor Cyan
$remainingViolations = npx markdownlint-cli2 "$FolderPath\*.md" --config .markdownlint.json 2>&1 | Where-Object { $_ -match "MD(012|009|037|022)" }

if ($remainingViolations) {
    $violationCount = ($remainingViolations | Measure-Object).Count
    Write-Host "⚠️ $violationCount violations remaining" -ForegroundColor Yellow
    if ($violationCount -le 10) {
        Write-Host "Remaining violations:" -ForegroundColor Yellow
        $remainingViolations | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    }
} else {
    Write-Host "🎉 ALL targeted violations eliminated!" -ForegroundColor Green
}