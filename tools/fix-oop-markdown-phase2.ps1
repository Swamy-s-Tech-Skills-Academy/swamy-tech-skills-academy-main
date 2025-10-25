# Fix OOP-Fundamentals Markdown Compliance - Phase 2
# Advanced regex patterns for complex markdown violations
# Status: Addressing 1028 remaining violations

param(
    [string]$FolderPath = "01_ReferenceLibrary\01_Development\01_software-design-principles\01_OOP-fundamentals"
)

$ErrorActionPreference = "Stop"

Write-Host "🎯 OOP-Fundamentals Markdown Compliance Fixer - Phase 2" -ForegroundColor Cyan
Write-Host "Target: 1028 violations -> 0 violations" -ForegroundColor Yellow
Write-Host "Priority: MD022 (421), MD032 (201), MD031 (99), MD024 (93)" -ForegroundColor Green
Write-Host ""

try {
    $files = Get-ChildItem -Path $FolderPath -Filter "*.md" -File
    Write-Host "📁 Processing $($files.Count) files..." -ForegroundColor Blue

    foreach ($file in $files) {
        Write-Host "  🔧 Fixing: $($file.Name)" -ForegroundColor Green
        
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $originalContent = $content

        # 1. MD022 - Blanks around headings (421 violations)
        # Add blank line before headings
        $content = $content -replace '(?m)^([^\n#])$\n(#{1,6}\s)', '$1\n\n$2'
        # Add blank line after headings
        $content = $content -replace '(?m)^(#{1,6}\s.+)$\n([^#\n])', '$1\n\n$2'

        # 2. MD032 - Blanks around lists (201 violations)
        # Add blank line before lists
        $content = $content -replace '(?m)^([^\n-])$\n(-\s)', '$1\n\n$2'
        $content = $content -replace '(?m)^([^\n\d])$\n(\d+\.\s)', '$1\n\n$2'
        # Add blank line after lists
        $content = $content -replace '(?m)^(-\s.+)$\n([^-\n])', '$1\n\n$2'
        $content = $content -replace '(?m)^(\d+\.\s.+)$\n([^\d\n])', '$1\n\n$2'

        # 3. MD031 - Blanks around fenced code blocks (99 violations)
        # Add blank line before code fences
        $content = $content -replace '(?m)^([^\n`])$\n(```)', '$1\n\n$2'
        # Add blank line after code fences
        $content = $content -replace '(?m)^(```)$\n([^`\n])', '$1\n\n$2'

        # 4. MD024 - Remove remaining duplicate headings (93 violations)
        # Convert duplicate section patterns to unique headings
        $content = $content -replace '(?m)^#### Definition$', '#### Definition and Purpose'
        $content = $content -replace '(?m)^#### Key Points$', '#### Key Implementation Points'
        $content = $content -replace '(?m)^#### Example$', '#### Code Implementation Example'

        # 5. MD036 - Fix remaining emphasis headings (57 violations)
        # Fix emphasis patterns that should be proper headings
        $content = $content -replace '\*\*([^*]+)\*\*(?=\s*$)', '#### $1'

        # 6. MD003 - Fix heading style (42 violations)
        # Remove trailing # from atx_closed headings
        $content = $content -replace '(?m)^(#{1,6}\s+.+?)\s*#+\s*$', '$1'

        # 7. MD046 - Fix code block style (34 violations)
        # Convert indented code to fenced when appropriate
        $content = $content -replace '(?m)^    ([^-].+)$', '```csharp\n$1\n```'

        # 8. MD047 - Single trailing newline (22 violations)
        # Ensure exactly one trailing newline
        $content = $content.TrimEnd("`r", "`n") + "`n"

        # 9. MD040 - Add language to code blocks (21 violations)
        # Add csharp to unlabeled code blocks
        $content = $content -replace '```\s*\n', '```csharp\n'

        # 10. MD001 - Fix heading increments (8 violations)
        # Fix skipped heading levels
        $content = $content -replace '(?m)^####([^#])', '###$1'

        # 11. MD058 - Blanks around tables (8 violations)
        # Add blank lines around tables
        $content = $content -replace '(?m)^([^\n|])$\n(\|)', '$1\n\n$2'
        $content = $content -replace '(?m)^(\|.+)$\n([^|\n])', '$1\n\n$2'

        # 12. MD026 - Remove trailing punctuation from headings (7 violations)
        $content = $content -replace '(?m)^(#{1,6}\s+.+)[.!?]+\s*$', '$1'

        # 13. MD029 - Fix ordered list prefixes (7 violations)
        # Standardize list numbering
        $listCounter = 0
        $content = [regex]::Replace($content, '(?m)^\d+\.\s', { 
            $script:listCounter++
            return "$script:listCounter. "
        })

        # 14. MD033 - Remove inline HTML (4 violations)
        $content = $content -replace '<([^/>]+)>', '`$1`'

        # 15. MD025 - Fix multiple H1s (2 violations)
        $h1Found = $false
        $content = [regex]::Replace($content, '(?m)^# (.+)$', {
            param($match)
            if ($script:h1Found) {
                return "## $($match.Groups[1].Value)"
            }
            $script:h1Found = $true
            return $match.Value
        })

        # 16. MD041 - Ensure first line is H1 (1 violation)
        if (-not ($content -match '^#\s+')) {
            $firstLine = ($content -split "`n")[0]
            $content = "# $firstLine`n`n" + $content
        }

        # 17. MD009 - Remove trailing spaces (1 violation)
        $content = $content -replace '(?m)\s+$', ''

        # Clean up multiple consecutive blank lines
        $content = $content -replace '\n{3,}', '\n\n'

        # Save if changed
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            Write-Host "    ✅ Applied advanced fixes to $($file.Name)" -ForegroundColor Green
        } else {
            Write-Host "    ℹ️  No changes needed for $($file.Name)" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "🎯 Running verification..." -ForegroundColor Cyan
    
    # Check remaining violations
    $violationCheck = npx markdownlint-cli2 "$FolderPath\*.md" 2>&1 | Where-Object { $_ -match "MD\d+" }
    
    if ($violationCheck) {
        $remainingCount = ($violationCheck | Measure-Object).Count
        Write-Host "📊 $remainingCount violations remaining (down from 1028)" -ForegroundColor Yellow
        
        # Show top violation types
        $topTypes = $violationCheck | ForEach-Object { ($_ -split ' ')[1] } | Group-Object | Sort-Object Count -Descending | Select-Object -First 5
        Write-Host "Top remaining violations:" -ForegroundColor Yellow
        $topTypes | ForEach-Object { Write-Host "  - $($_.Name): $($_.Count)" -ForegroundColor White }
    } else {
        Write-Host "🎉 SUCCESS: All violations fixed! OOP-fundamentals is 100% compliant!" -ForegroundColor Green
    }

} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📊 Next: Run final verification to confirm A grade achievement" -ForegroundColor Blue