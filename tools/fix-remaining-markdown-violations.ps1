# Fix Remaining Markdown Violations in SOLID-Principles
# Targets: MD012, MD009, MD037, MD022

param(
    [Parameter(Mandatory=$false)]
    [string]$FolderPath = "01_ReferenceLibrary\01_Development\01_software-design-principles\02_SOLID-Principles"
)

$ErrorActionPreference = "Stop"

Write-Host "🔧 Fixing remaining markdown violations in SOLID-Principles folder" -ForegroundColor Yellow
Write-Host "📁 Target: $FolderPath" -ForegroundColor Cyan

# Get all markdown files
$files = Get-ChildItem $FolderPath -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }

Write-Host "📋 Found $($files.Count) files to process" -ForegroundColor Green

$totalFixed = 0

foreach ($file in $files) {
    Write-Host "🔍 Processing: $($file.Name)" -ForegroundColor Cyan
    
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fileFixed = 0
    
    # Fix MD012: Multiple consecutive blank lines
    # Replace 3+ consecutive newlines with 2 newlines (1 blank line)
    $content = $content -replace "`r?`n`r?`n`r?`n+", "`n`n"
    if ($content -ne $originalContent) {
        $matches = [regex]::Matches($originalContent, "`r?`n`r?`n`r?`n+").Count
        Write-Host "  ✅ Fixed $matches MD012 violations (multiple blank lines)" -ForegroundColor Green
        $fileFixed += $matches
    }
    
    # Fix MD009: Trailing spaces
    # Remove trailing spaces from lines (but preserve intentional 2-space line breaks)
    $lines = $content -split "`r?`n"
    $fixedLines = @()
    $trailingSpacesFixed = 0
    
    foreach ($line in $lines) {
        if ($line -match "^(.*)[ ]{3,}$") {
            # Line has 3+ trailing spaces - remove excess, keep 0 or 2
            $fixedLine = $line -replace "[ ]{3,}$", ""
            $fixedLines += $fixedLine
            $trailingSpacesFixed++
        } elseif ($line -match "^(.*)[ ]{1}$") {
            # Line has exactly 1 trailing space - remove it
            $fixedLine = $line -replace "[ ]{1}$", ""
            $fixedLines += $fixedLine
            $trailingSpacesFixed++
        } else {
            # Line is fine (0 or 2 trailing spaces)
            $fixedLines += $line
        }
    }
    
    if ($trailingSpacesFixed -gt 0) {
        $content = $fixedLines -join "`n"
        Write-Host "  ✅ Fixed $trailingSpacesFixed MD009 violations (trailing spaces)" -ForegroundColor Green
        $fileFixed += $trailingSpacesFixed
    }
    
    # Fix MD037: Spaces inside emphasis markers
    # Pattern: word _text text_ -> word_text text_
    $md037Matches = [regex]::Matches($content, "[a-zA-Z] _([^_]+)_ ").Count
    $content = $content -replace "([a-zA-Z]) _([^_]+)_ ", '$1_$2_ '
    if ($md037Matches -gt 0) {
        Write-Host "  ✅ Fixed $md037Matches MD037 violations (spaces in emphasis)" -ForegroundColor Green
        $fileFixed += $md037Matches
    }
    
    # Fix MD022: Headings should be surrounded by blank lines
    # Add blank line before headings that don't have one
    $lines = $content -split "`r?`n"
    $fixedLines = @()
    $headingFixed = 0
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $currentLine = $lines[$i]
        
        # Check if current line is a heading (starts with #)
        if ($currentLine -match "^#{1,6} ") {
            # Check if previous line exists and is not blank
            if ($i -gt 0 -and $lines[$i-1].Trim() -ne "") {
                # Add blank line before heading
                $fixedLines += ""
                $headingFixed++
            }
        }
        
        $fixedLines += $currentLine
    }
    
    if ($headingFixed -gt 0) {
        $content = $fixedLines -join "`n"
        Write-Host "  ✅ Fixed $headingFixed MD022 violations (heading spacing)" -ForegroundColor Green
        $fileFixed += $headingFixed
    }
    
    # Write back to file if changes were made
    if ($content -ne $originalContent) {
        $content | Set-Content $file.FullName -NoNewline
        Write-Host "  💾 Saved changes to $($file.Name)" -ForegroundColor Green
        $totalFixed += $fileFixed
    } else {
        Write-Host "  ✨ No violations found in $($file.Name)" -ForegroundColor Gray
    }
}

Write-Host "`n🎉 SUMMARY:" -ForegroundColor Yellow
Write-Host "📁 Files processed: $($files.Count)" -ForegroundColor Cyan
Write-Host "🔧 Total violations fixed: $totalFixed" -ForegroundColor Green

# Verify the fixes
Write-Host "`n🔍 Verifying fixes..." -ForegroundColor Cyan
$remainingViolations = npx markdownlint-cli2 "$FolderPath\*.md" --config .markdownlint.json 2>&1 | Where-Object { $_ -match "MD(012|009|037|022)" }

if ($remainingViolations) {
    Write-Host "⚠️ Remaining violations:" -ForegroundColor Yellow
    $remainingViolations | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
} else {
    Write-Host "🎉 All targeted violations fixed!" -ForegroundColor Green
}