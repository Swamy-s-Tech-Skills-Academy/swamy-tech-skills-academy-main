# Fix MD046 Code Block Style Violations in Specific File
# Converts fenced code blocks (```) to indented format

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

$ErrorActionPreference = "Stop"

Write-Host "🔧 Fixing MD046 violations in: $FilePath" -ForegroundColor Yellow

# Read the file content
if (-not (Test-Path $FilePath)) {
    Write-Host "❌ File not found: $FilePath" -ForegroundColor Red
    exit 1
}

$content = Get-Content $FilePath -Raw
$lines = Get-Content $FilePath

Write-Host "📁 File loaded: $($lines.Count) lines" -ForegroundColor Green

# Pattern to match fenced code blocks
$fencedBlockPattern = '```(\w+)?\r?\n(.*?)\r?\n```'

$newContent = $content

# Find and replace fenced blocks with indented blocks
$matches = [regex]::Matches($content, $fencedBlockPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

Write-Host "🔍 Found $($matches.Count) fenced code blocks" -ForegroundColor Cyan

foreach ($match in $matches) {
    $fullMatch = $match.Value
    $language = $match.Groups[1].Value
    $code = $match.Groups[2].Value
    
    # Convert each line of code to indented format (4 spaces)
    $indentedLines = $code -split "`r?`n" | ForEach-Object {
        if ($_.Trim() -eq "") {
            ""  # Keep empty lines empty
        } else {
            "    $_"  # Add 4-space indentation
        }
    }
    
    $indentedCode = $indentedLines -join "`n"
    
    # Replace fenced block with indented block
    $newContent = $newContent.Replace($fullMatch, $indentedCode)
    
    Write-Host "✅ Converted fenced block (language: $language)" -ForegroundColor Green
}

# Handle malformed blocks (e.g., ```csharp without closing ```)
$malformedPattern = '```(\w+)(?!\r?\n.*?\r?\n```)'
$malformedMatches = [regex]::Matches($newContent, $malformedPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

Write-Host "🔧 Found $($malformedMatches.Count) malformed blocks" -ForegroundColor Yellow

foreach ($malformedMatch in $malformedMatches) {
    $malformedText = $malformedMatch.Value
    $newContent = $newContent.Replace($malformedText, "")
    Write-Host "🗑️ Removed malformed block: $malformedText" -ForegroundColor DarkYellow
}

# Write the corrected content back to file
$newContent | Set-Content $FilePath -NoNewline

Write-Host "💾 File updated successfully" -ForegroundColor Green

# Verify the fix by running markdownlint on this specific file
Write-Host "🔍 Verifying MD046 fixes..." -ForegroundColor Cyan
$lintResult = npx markdownlint-cli2 $FilePath 2>&1 | Where-Object { $_ -match "MD046" }

if ($lintResult) {
    Write-Host "⚠️ Remaining MD046 violations:" -ForegroundColor Yellow
    $lintResult | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
} else {
    Write-Host "🎉 All MD046 violations fixed!" -ForegroundColor Green
}