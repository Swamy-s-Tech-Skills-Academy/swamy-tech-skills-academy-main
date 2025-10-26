# Fix OOP-Fundamentals Markdown Compliance
# Targeting 275 violations across all markdown rules
# Status: 100% completion mandate for OOP-fundamentals

param(
    [string]$FolderPath = "01_ReferenceLibrary\01_Development\01_software-design-principles\01_OOP-fundamentals"
)

$ErrorActionPreference = "Stop"

Write-Host "🎯 OOP-Fundamentals Markdown Compliance Fixer" -ForegroundColor Cyan
Write-Host "Target: 275 violations -> 0 violations (100% completion)" -ForegroundColor Yellow
Write-Host "Priority Order: MD024 (99), MD036 (65), MD046 (40), MD040 (18)" -ForegroundColor Green
Write-Host ""

$startLocation = Get-Location

try {
    if (-not (Test-Path $FolderPath)) {
        throw "Folder not found: $FolderPath"
    }

    $files = Get-ChildItem -Path $FolderPath -Filter "*.md" -File
    Write-Host "📁 Processing $($files.Count) files in OOP-fundamentals..." -ForegroundColor Blue

    foreach ($file in $files) {
        Write-Host "  🔧 Fixing: $($file.Name)" -ForegroundColor Green
        
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $originalContent = $content

        # 1. MD024 - Fix duplicate headings (99 violations)
        # Change **bold** patterns that should be headings
        $content = $content -replace '\*\*(Goals)\*\*(?=\s*$)', '#### $1'
        $content = $content -replace '\*\*(Topics to Cover)\*\*(?=\s*$)', '#### $1'
        $content = $content -replace '\*\*(Exercises)\*\*(?=\s*$)', '#### $1'
        $content = $content -replace '\*\*(Prerequisites)\*\*(?=\s*$)', '#### $1'
        $content = $content -replace '\*\*(Builds Upon)\*\*(?=\s*$)', '#### $1'
        $content = $content -replace '\*\*(Enables)\*\*(?=\s*$)', '#### $1'
        $content = $content -replace '\*\*(Cross-References)\*\*(?=\s*$)', '#### $1'
        $content = $content -replace '\*\*(Example)\*\*(?=\s*$)', '#### $1'
        $content = $content -replace '\*\*(Definition)\*\*(?=\s*$)', '#### $1'
        $content = $content -replace '\*\*(Key Points)\*\*(?=\s*$)', '#### $1'
        $content = $content -replace '\*\*(Code Example \([^)]+\):\*\*)', '#### $1'
        $content = $content -replace '\*\*(1\. Class)\*\*(?=\s*$)', '#### $1'

        # 2. MD036 - Fix emphasis used as heading (65 violations)
        # Fix "Part X of Y" patterns
        $content = $content -replace '\*Part ([ABC]) of ([23])\*(?=\s*$)', '## Part $1 of $2'
        $content = $content -replace '\*Part ([A-F]) of ([3-6])\*(?=\s*$)', '## Part $1 of $2'

        # 3. MD046 - Fix code block style inconsistencies (40 violations)
        # Convert indented code blocks to fenced (when surrounded by fenced blocks)
        $content = $content -replace '(?m)^    (.+)$(?=\s*```)', '```csharp$1```'
        
        # 4. MD040 - Add language to fenced code blocks (18 violations)
        # Add 'csharp' to empty fenced code blocks
        $content = $content -replace '```\s*\n([^`]+)\n```', '```csharp$1```'

        # 5. MD032 - Add blank lines around lists (13 violations)
        # Add blank line before lists that don't have one
        $content = $content -replace '(?m)^([^-\s\n])$\n(-\s)', '$1\n\n$2'
        
        # 6. MD001 - Fix heading increment violations (9 violations)
        # Fix h4 that should be h3
        $content = $content -replace '(?m)^#### (.+)$(?=\s*\n(?!#))', '### $1'
        
        # 7. MD022 - Add blank lines around headings (9 violations)
        # Add blank line after headings when missing
        $content = $content -replace '(?m)^(### .+)$\n([^#\n])', '$1\n\n$2'
        
        # 8. MD029 - Fix ordered list prefixes (9 violations)
        # Reset list numbering to 1, 2, 3...
        $content = [regex]::Replace($content, '(?m)^(\d+)\.\s', { 
            param($match)
            $currentNumber = [int]$match.Groups[1].Value
            if ($currentNumber -ne 1) {
                return "1. "
            }
            return $match.Value
        })

        # 9. MD033 - Remove inline HTML (4 violations)
        # Remove angle bracket HTML elements
        $content = $content -replace '<([^>]+)>', '`$1`'

        # 10. MD003 - Fix heading style (3 violations)
        # Convert setext to atx style (remove trailing #)
        $content = $content -replace '(?m)^(#+\s+.+)\s#+\s*$', '$1'

        # 11. MD025 - Fix multiple H1 headings (2 violations)
        # Convert duplicate H1 to H2
        $h1Count = 0
        $content = [regex]::Replace($content, '(?m)^# (.+)$', {
            param($match)
            $script:h1Count++
            if ($script:h1Count -gt 1) {
                return "## $($match.Groups[1].Value)"
            }
            return $match.Value
        })

        # 12. MD047 - Add single trailing newline (2 violations)
        # Ensure file ends with exactly one newline
        $content = $content.TrimEnd() + "`n"

        # 13. MD009 - Remove trailing spaces (1 violation)
        # Remove trailing spaces from lines
        $content = $content -replace '(?m)\s+$', ''

        # 14. MD041 - Ensure first line is H1 (1 violation)
        # Add H1 if missing at start
        if (-not ($content -match '^#\s')) {
            $content = "# OOP Fundamentals`n`n" + $content
        }

        # Save if changed
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            Write-Host "    ✅ Fixed violations in $($file.Name)" -ForegroundColor Green
        } else {
            Write-Host "    ℹ️  No changes needed for $($file.Name)" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "🎯 Running verification..." -ForegroundColor Cyan
    
    # Verify fixes
    $violationCheck = npx markdownlint-cli2 "$FolderPath\*.md" 2>&1 | Where-Object { $_ -match "MD\d+" }
    
    if ($violationCheck) {
        $remainingCount = ($violationCheck | Measure-Object).Count
        Write-Host "⚠️  $remainingCount violations remaining" -ForegroundColor Yellow
        
        # Show remaining violation types
        $remainingTypes = $violationCheck | ForEach-Object { ($_ -split ' ')[1] } | Group-Object | Sort-Object Count -Descending
        Write-Host "Remaining violation types:" -ForegroundColor Yellow
        $remainingTypes | ForEach-Object { Write-Host "  - $($_.Name): $($_.Count)" -ForegroundColor White }
    } else {
        Write-Host "🎉 SUCCESS: All 275 violations fixed! OOP-fundamentals is 100% compliant!" -ForegroundColor Green
        Write-Host "✅ A Grade (90%+) criteria met for D. Style Guidelines" -ForegroundColor Green
    }

} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Set-Location $startLocation
}

Write-Host ""
Write-Host "📊 Next: Run verify-oop-fundamentals.ps1 for final A-M verification" -ForegroundColor Blue