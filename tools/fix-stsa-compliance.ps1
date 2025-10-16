# STSA Content Compliance Fixer
# Fixes character encoding and length issues
# Created: October 16, 2025

param(
    [string]$Path = "01_ReferenceLibrary\01_Development\01_software-design-principles\01_OOP-fundamentals",
    [switch]$WhatIf
)

$MaxLines = 175

Write-Host "=== STSA Content Compliance Fixer ===" -ForegroundColor Cyan
Write-Host "Path: $Path" -ForegroundColor Yellow
Write-Host "Max Lines: $MaxLines" -ForegroundColor Yellow

if ($WhatIf) {
    Write-Host "WHATIF MODE - No changes will be made" -ForegroundColor Magenta
}

$files = Get-ChildItem -Path $Path -Filter "*.md"
$issuesFound = 0
$filesFixed = 0

foreach ($file in $files) {
    Write-Host "`n--- Processing: $($file.Name) ---" -ForegroundColor Green
    
    # Check line count
    $lineCount = (Get-Content $file.FullName | Measure-Object -Line).Lines
    if ($lineCount -gt $MaxLines) {
        Write-Host "  ❌ OVERSIZED: $lineCount lines (exceeds $MaxLines)" -ForegroundColor Red
        $issuesFound++
        
        if (-not $WhatIf) {
            # Create backup
            $backup = $file.FullName + ".backup"
            Copy-Item $file.FullName $backup
            Write-Host "  📁 Created backup: $backup" -ForegroundColor Blue
        }
    } else {
        Write-Host "  ✅ SIZE OK: $lineCount lines" -ForegroundColor Green
    }
    
    # Check for character encoding issues
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $hasEncodingIssues = $false
    
    # Simple check for common problem patterns
    if ($content -match "ðŸ|â|Ã") {
        Write-Host "  ❌ ENCODING: Found corrupted characters" -ForegroundColor Red
        $hasEncodingIssues = $true
        $issuesFound++
        
        if (-not $WhatIf) {
            # Create backup if not already done
            $backup = $file.FullName + ".backup"
            if (-not (Test-Path $backup)) {
                Copy-Item $file.FullName $backup
                Write-Host "  📁 Created backup: $backup" -ForegroundColor Blue
            }
            
            # Fix common corrupted patterns
            $fixed = $content
            $fixed = $fixed -replace "ðŸŽ¯", "🎯"   # Target
            $fixed = $fixed -replace "ðŸ"‹", "📋"   # Clipboard
            $fixed = $fixed -replace "ðŸ"—", "🔗"   # Link
            $fixed = $fixed -replace "âœ…", "✅"   # Checkmark
            $fixed = $fixed -replace "âŒ", "❌"    # Cross
            $fixed = $fixed -replace "ðŸš¨", "🚨"   # Warning
            $fixed = $fixed -replace "ðŸ'¡", "💡"   # Lightbulb
            $fixed = $fixed -replace "ðŸŽ¨", "🎨"   # Palette
            $fixed = $fixed -replace "ðŸ"Š", "📊"   # Chart
            $fixed = $fixed -replace "ðŸ"š", "📚"   # Books
            $fixed = $fixed -replace "ðŸš€", "🚀"   # Rocket
            $fixed = $fixed -replace "â­", "⭐"    # Star
            
            # Fix box drawing characters with ASCII
            $fixed = $fixed -replace "â"Œ", "┌"
            $fixed = $fixed -replace "â"€", "─"
            $fixed = $fixed -replace "â"", "┐"
            $fixed = $fixed -replace "â"‚", "│"
            $fixed = $fixed -replace "â"œ", "├"
            $fixed = $fixed -replace "â"¤", "┤"
            $fixed = $fixed -replace "â"", "└"
            $fixed = $fixed -replace "â"˜", "┘"
            
            # Save fixed content
            $fixed | Set-Content $file.FullName -Encoding UTF8 -NoNewline
            Write-Host "  🔧 Fixed encoding issues" -ForegroundColor Green
            $filesFixed++
        }
    } else {
        Write-Host "  ✅ ENCODING OK: No corrupted characters found" -ForegroundColor Green
    }
    
    # Check for proper STSA structure
    if ($content -notmatch "Learning Level.*Prerequisites.*Estimated Time") {
        Write-Host "  ⚠️  STRUCTURE: Missing STSA metadata" -ForegroundColor Yellow
        $issuesFound++
    } else {
        Write-Host "  ✅ STRUCTURE OK: STSA metadata present" -ForegroundColor Green
    }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Files processed: $($files.Count)" -ForegroundColor White
Write-Host "Issues found: $issuesFound" -ForegroundColor Yellow
Write-Host "Files fixed: $filesFixed" -ForegroundColor Green

if ($issuesFound -gt 0 -and -not $WhatIf) {
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "1. Review fixed files for correctness" -ForegroundColor White
    Write-Host "2. Split oversized files manually into parts" -ForegroundColor White
    Write-Host "3. Test markdown preview" -ForegroundColor White
    Write-Host "4. Run markdown lint validation" -ForegroundColor White
}

if ($WhatIf -and $issuesFound -gt 0) {
    Write-Host "`nRe-run without -WhatIf to apply fixes" -ForegroundColor Magenta
}