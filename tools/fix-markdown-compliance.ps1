#!/usr/bin/env pwsh

<#
.SYNOPSIS
Fix markdown compliance violations in OOP-fundamentals folder

.DESCRIPTION
Systematically fixes common markdown lint violations:
- MD012: Multiple consecutive blank lines
- MD022: Missing blank lines around headings
- Unicode corruption in headings

.PARAMETER FolderPath
Path to the folder containing markdown files to fix

.EXAMPLE
.\tools\fix-markdown-compliance.ps1 -FolderPath "01_ReferenceLibrary\01_Development\01_software-design-principles\01_oop-fundamentals"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

$ErrorActionPreference = "Stop"

Write-Host "🔧 MARKDOWN COMPLIANCE FIXER" -ForegroundColor Yellow
Write-Host "Target Folder: $FolderPath" -ForegroundColor Cyan
Write-Host ""

# Get all markdown files
$markdownFiles = Get-ChildItem -Path $FolderPath -Filter "*.md" -File

Write-Host "📄 Found $($markdownFiles.Count) markdown files" -ForegroundColor Green
Write-Host ""

$filesFixed = 0

foreach ($file in $markdownFiles) {
    Write-Host "🔧 Processing: $($file.Name)" -ForegroundColor Yellow
    
    # Read content
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Fix 1: Remove multiple consecutive blank lines (MD012)
    $content = $content -replace "`r`n`r`n`r`n+", "`r`n`r`n"
    
    # Fix 2: Ensure blank lines around headings (MD022) - more comprehensive
    # Add blank line before headings if missing (after metadata block)
    $content = $content -replace "([^\r\n])`r`n(#{1,6}\s)", "`$1`r`n`r`n`$2"
    
    # Special fix for headings after --- separator
    $content = $content -replace "(---)`r`n(#{1,6}\s)", "`$1`r`n`r`n`$2"
    
    # Add blank line after headings if missing  
    $content = $content -replace "(#{1,6}\s[^\r\n]*)`r`n([^`r`n#])", "`$1`r`n`r`n`$2"
    
    # Fix 3: Unicode corruption in headings (common patterns)
    $content = $content -replace "≡ƒÄ»", "🎯"  # Learning Objectives emoji
    $content = $content -replace "≡ƒôÄ", "📋"  # Content Sections emoji
    $content = $content -replace "≡ƒöÉ", "🔗"  # Related Topics emoji
    $content = $content -replace "≡ƒÜä", "⚠️"   # Warning emoji
    $content = $content -replace "≡ƒöî", "✅"   # Check mark emoji
    
    # Fix 4: Convert emphasis to proper headings (MD036)
    $content = $content -replace "^\*\*Part ([AB]) of \d+\*\*$", "### Part `$1"
    
    # Fix 5: Code block consistency (MD046) - prefer fenced over indented
    # This is complex and might need manual review, but we'll standardize basic patterns
    
    # Fix 6: Remove trailing whitespace
    $lines = $content -split "`r`n"
    $lines = $lines | ForEach-Object { $_.TrimEnd() }
    $content = $lines -join "`r`n"
    
    # Fix 7: Ensure file ends with single newline
    $content = $content.TrimEnd() + "`r`n"
    
    # Check if changes were made
    if ($content -ne $originalContent) {
        # Write fixed content back
        Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
        Write-Host "  ✅ Fixed compliance issues" -ForegroundColor Green
        $filesFixed++
    } else {
        Write-Host "  ℹ️  No issues found" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "📊 SUMMARY" -ForegroundColor Yellow
Write-Host "Files processed: $($markdownFiles.Count)" -ForegroundColor Cyan
Write-Host "Files fixed: $filesFixed" -ForegroundColor Green

if ($filesFixed -gt 0) {
    Write-Host ""
    Write-Host "🔍 Running markdown lint verification..." -ForegroundColor Yellow
    
    try {
        $lintResult = npx markdownlint-cli2 "$FolderPath\*.md" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ All markdown compliance issues fixed!" -ForegroundColor Green
        } else {
            $errorCount = ($lintResult | Where-Object { $_ -match "error\(s\)" } | Select-Object -First 1) -replace ".*Summary: (\d+) error\(s\).*", '$1'
            Write-Host "⚠️  $errorCount markdown issues remaining" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "ℹ️  Lint verification skipped (markdownlint not available)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "✅ Markdown compliance fixing complete!" -ForegroundColor Green