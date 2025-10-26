# Fix Unicode Character Encoding Corruption in OOP-fundamentals
# Addresses critical character encoding issues identified in A-M verification

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath,
    
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

# Define Unicode corruption mappings
$UnicodeReplacements = @{
    # Corrupted emoji targets
    "ðŸŽ¯" = "🎯"
    "ðŸ"—" = "🔗"
    "ðŸ"Š" = "📊"
    "ðŸš€" = "🚀"
    
    # Corrupted punctuation
    "â€™" = "'"
    "â€œ" = '"'
    "â€" = '"'
    "â€"" = "—"
    "â€'" = "–"
    
    # Corrupted arrows and symbols
    "â†'" = "→"
    "â†" = "←"
    "â†'" = "↑"
    "â†"" = "↓"
    "â†"" = "↔"
    
    # Other common corruptions
    "â€¦" = "…"
    "Â" = ""
    "â€‹" = ""
}

Write-Host "🔧 Starting Unicode encoding fix for: $FolderPath" -ForegroundColor Cyan

# Get all markdown files
$MarkdownFiles = Get-ChildItem -Path $FolderPath -Filter "*.md" -Recurse

Write-Host "📁 Found $($MarkdownFiles.Count) markdown files to process" -ForegroundColor Green

$FilesModified = 0
$TotalReplacements = 0

foreach ($File in $MarkdownFiles) {
    Write-Host "🔍 Processing: $($File.Name)" -ForegroundColor Yellow
    
    # Read file content
    $Content = Get-Content -Path $File.FullName -Raw -Encoding UTF8
    $OriginalContent = $Content
    $FileReplacements = 0
    
    # Apply all replacements
    foreach ($Corruption in $UnicodeReplacements.Keys) {
        $Replacement = $UnicodeReplacements[$Corruption]
        $OccurrenceCount = ($Content -split [regex]::Escape($Corruption)).Count - 1
        
        if ($OccurrenceCount -gt 0) {
            Write-Host "  ↳ Replacing '$Corruption' → '$Replacement' ($OccurrenceCount occurrences)" -ForegroundColor Magenta
            $Content = $Content -replace [regex]::Escape($Corruption), $Replacement
            $FileReplacements += $OccurrenceCount
        }
    }
    
    # Check if file was modified
    if ($Content -ne $OriginalContent) {
        if ($WhatIf) {
            Write-Host "  ✅ WOULD MODIFY: $($File.Name) ($FileReplacements replacements)" -ForegroundColor Green
        } else {
            # Write back to file with UTF-8 encoding
            Set-Content -Path $File.FullName -Value $Content -Encoding UTF8 -NoNewline
            Write-Host "  ✅ FIXED: $($File.Name) ($FileReplacements replacements)" -ForegroundColor Green
        }
        $FilesModified++
        $TotalReplacements += $FileReplacements
    } else {
        Write-Host "  ✓ Clean: $($File.Name)" -ForegroundColor DarkGreen
    }
}

Write-Host ""
Write-Host "📊 SUMMARY:" -ForegroundColor Cyan
Write-Host "  Files processed: $($MarkdownFiles.Count)" -ForegroundColor White
Write-Host "  Files modified: $FilesModified" -ForegroundColor White
Write-Host "  Total replacements: $TotalReplacements" -ForegroundColor White

if ($WhatIf) {
    Write-Host "  Mode: PREVIEW ONLY (use -WhatIf `$false to apply changes)" -ForegroundColor Yellow
} else {
    Write-Host "  Mode: CHANGES APPLIED" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎯 Unicode encoding fix complete!" -ForegroundColor Green