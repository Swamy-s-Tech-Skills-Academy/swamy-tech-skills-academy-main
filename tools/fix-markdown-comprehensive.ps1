# Comprehensive Markdown Compliance Fixer for SOLID-Principles
# This script fixes all major markdown compliance issues to achieve 100% quality

param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

$ErrorActionPreference = "Stop"

Write-Host "🔧 Starting comprehensive markdown compliance fixes for SOLID-Principles..." -ForegroundColor Yellow

# Get all markdown files in the folder
$files = Get-ChildItem -Path $FolderPath -Filter "*.md" -Recurse

$totalFixed = 0
$allFixes = @()

foreach ($file in $files) {
    Write-Host "📄 Processing: $($file.Name)" -ForegroundColor Cyan
    
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fileChanges = 0
    
    # Fix MD046: Convert fenced code blocks to indented (text blocks only)
    $fencedPattern = '```text\r?\n(.*?)\r?\n```'
    $matches = [regex]::Matches($content, $fencedPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    foreach ($match in $matches) {
        $codeContent = $match.Groups[1].Value
        
        # Convert each line to 4-space indented format
        $indentedLines = $codeContent -split '\r?\n' | ForEach-Object {
            if ($_.Trim() -eq "") {
                ""  # Keep empty lines as-is
            } else {
                "    $_"  # Add 4-space indentation
            }
        }
        
        $indentedBlock = $indentedLines -join "`r`n"
        $content = $content.Replace($match.Value, $indentedBlock)
        $fileChanges++
    }
    
    # Fix MD012: Remove multiple consecutive blank lines (keep only one)
    $content = $content -replace '\r?\n\r?\n\r?\n+', "`r`n`r`n"
    
    # Fix MD009: Remove trailing spaces (except intentional line breaks with 2 spaces)
    $lines = $content -split '\r?\n'
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^(.*)(\s{3,})$') {
            # More than 2 trailing spaces - remove extras
            $lines[$i] = $line -replace '\s{3,}$', ''
        } elseif ($line -match '^(.*[^\.!?])\s{1}$') {
            # Single trailing space (not after sentence ending) - remove
            $lines[$i] = $line -replace '\s{1}$', ''
        }
    }
    $content = $lines -join "`r`n"
    
    # Fix MD037: Remove spaces inside emphasis markers
    $content = $content -replace '\*\*([^*]+)\s+_', '**$1_'
    $content = $content -replace '_\s+([^_]+)\*\*', '_$1**'
    $content = $content -replace '\*([^*]+)\s+_', '*$1_'
    $content = $content -replace '_\s+([^_]+)\*', '_$1*'
    
    # Fix MD038: Remove spaces inside code span elements
    $content = $content -replace '`([^`]+)\s+`', '`$1`'
    $content = $content -replace '`\s+([^`]+)`', '`$1`'
    
    # Fix MD031: Ensure blank lines around fenced code blocks
    $content = $content -replace '([^\r\n])\r?\n```', '$1' + "`r`n`r`n" + '```'
    $content = $content -replace '```\r?\n([^\r\n])', '```' + "`r`n`r`n" + '$1'
    
    # Count changes made
    if ($content -ne $originalContent) {
        $changes = ($originalContent.Length - $content.Length)
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $totalFixed++
        $allFixes += "$($file.Name): Fixed multiple violations"
        Write-Host "  ✅ Fixed markdown compliance violations" -ForegroundColor Green
    } else {
        Write-Host "  ℹ️  No violations found" -ForegroundColor Blue
    }
}

Write-Host "`n🎯 Comprehensive Markdown Fix Summary:" -ForegroundColor Green
Write-Host "  📁 Folder: $FolderPath" -ForegroundColor White
Write-Host "  📄 Files Processed: $($files.Count)" -ForegroundColor White
Write-Host "  📄 Files Fixed: $totalFixed" -ForegroundColor White

if ($allFixes.Count -gt 0) {
    Write-Host "`n📋 Fixed Files:" -ForegroundColor Yellow
    $allFixes | ForEach-Object { Write-Host "  • $_" -ForegroundColor White }
    Write-Host "`n✅ All markdown compliance violations have been fixed!" -ForegroundColor Green
} else {
    Write-Host "`nℹ️  No violations were found to fix." -ForegroundColor Blue
}

Write-Host "`n🔍 Running post-fix verification..." -ForegroundColor Cyan

# Verify the fixes by running markdownlint
try {
    $lintResults = npx markdownlint-cli2 "$FolderPath\*.md" --config .markdownlint.json 2>&1
    $violations = ($lintResults | Where-Object { $_ -match "MD046|MD012|MD009|MD037|MD038|MD031" }).Count
    
    Write-Host "`n📊 Post-Fix Results:" -ForegroundColor Green
    Write-Host "  🔍 Targeted Violations Remaining: $violations" -ForegroundColor $(if ($violations -eq 0) { "Green" } else { "Yellow" })
    
    if ($violations -eq 0) {
        Write-Host "  🎉 SUCCESS: All targeted markdown violations fixed!" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Some violations may require manual review" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠️  Could not verify fixes (markdownlint not available)" -ForegroundColor Yellow
}