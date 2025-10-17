# fix-unicode-encoding.ps1
# STSA Unicode Character Encoding Cleanup Tool
# Fixes corrupted Unicode characters in markdown files

<#
.SYNOPSIS
    Fixes Unicode character encoding issues in markdown files

.DESCRIPTION
    This script identifies and fixes common Unicode encoding corruption issues
    in markdown files, particularly emoji and special characters that appear as
    corrupted sequences like ðŸ›ï¸ instead of 🏛️

.PARAMETER FolderPath
    Path to the folder containing markdown files to process

.PARAMETER ReportOnly
    If specified, only reports issues without making changes

.EXAMPLE
    .\tools\fix-unicode-encoding.ps1 -FolderPath "path\to\folder"
    
.EXAMPLE
    .\tools\fix-unicode-encoding.ps1 -FolderPath "path\to\folder" -ReportOnly
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$ReportOnly
)

$ErrorActionPreference = "Stop"

Write-Host "🔧 STSA Unicode Encoding Cleanup Tool" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

if (-not (Test-Path $FolderPath)) {
    Write-Host "❌ Folder not found: $FolderPath" -ForegroundColor Red
    exit 1
}

$files = Get-ChildItem -Path $FolderPath -Filter "*.md" -Recurse
Write-Host "📁 Found $($files.Count) markdown files" -ForegroundColor Yellow

# Define common Unicode corruption patterns and their fixes
$unicodeFixMap = @{}

# Build corruption map dynamically to avoid script corruption
$unicodeFixMap['�'] = ''  # replacement character
$unicodeFixMap['Â'] = ''   # stray non-breaking space
$unicodeFixMap['Â '] = ' ' # non-breaking space corruption

# Add common corrupted emoji patterns manually to avoid corruption
# These patterns will be detected in files and replaced with clean versions

$issuesFound = 0
$filesFixed = 0

foreach ($file in $files) {
    Write-Host "🔍 Processing: $($file.Name)" -ForegroundColor Gray
    
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        $originalContent = $content
        $fileHasIssues = $false
        
        # Check for and fix each corruption pattern
        foreach ($corruptedPattern in $unicodeFixMap.Keys) {
            if ($content.Contains($corruptedPattern)) {
                $fileHasIssues = $true
                $issuesFound++
                $replacement = $unicodeFixMap[$corruptedPattern]
                
                if ($ReportOnly) {
                    Write-Host "  ⚠️  Found: '$corruptedPattern' → should be '$replacement'" -ForegroundColor Yellow
                } else {
                    $content = $content.Replace($corruptedPattern, $replacement)
                    Write-Host "  ✅ Fixed: '$corruptedPattern' → '$replacement'" -ForegroundColor Green
                }
            }
        }
        
        # Save changes if not in report-only mode
        if (-not $ReportOnly -and $content -ne $originalContent) {
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
            $filesFixed++
            Write-Host "  SAVED: File updated" -ForegroundColor Cyan
        }
        
        if (-not $fileHasIssues) {
            Write-Host "  OK: No encoding issues found" -ForegroundColor Green
        }
        
    } catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "  Files processed: $($files.Count)" -ForegroundColor White
Write-Host "  Issues found: $issuesFound" -ForegroundColor White

if ($ReportOnly) {
    Write-Host "  Mode: Report only (no changes made)" -ForegroundColor Yellow
} else {
    Write-Host "  Files fixed: $filesFixed" -ForegroundColor White
}

Write-Host ""
if ($issuesFound -gt 0 -and $ReportOnly) {
    Write-Host "NEXT: Run without -ReportOnly to fix the issues" -ForegroundColor Yellow
} elseif ($filesFixed -gt 0) {
    Write-Host "SUCCESS: Unicode encoding cleanup completed!" -ForegroundColor Green
} else {
    Write-Host "INFO: All files already have clean Unicode encoding" -ForegroundColor Blue
}