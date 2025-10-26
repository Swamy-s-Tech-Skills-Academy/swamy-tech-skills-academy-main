# SOLID Principles Markdown Compliance Fix Script
# This script systematically fixes markdown violations in SOLID-Principles folder

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

# Define the target folder
$SolidPrinciplesPath = "01_ReferenceLibrary\01_Development\01_software-design-principles\02_SOLID-Principles"

Write-Host "🔧 Starting SOLID Principles Markdown Compliance Fix" -ForegroundColor Cyan
Write-Host "Target Path: $SolidPrinciplesPath" -ForegroundColor White

# Get all markdown files
$MarkdownFiles = Get-ChildItem -Path $SolidPrinciplesPath -Filter "*.md"

Write-Host "📝 Found $($MarkdownFiles.Count) markdown files to process" -ForegroundColor Yellow

foreach ($file in $MarkdownFiles) {
    Write-Host "`n🔍 Processing: $($file.Name)" -ForegroundColor Green
    
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Fix 1: Replace emphasis with proper headings for Part markers
    # Convert "**Part X of Y**" to proper headings
    $content = $content -replace '\*\*(Part [A-Z] of \d+)\*\*', '## $1'
    
    # Fix 2: Add language to code blocks (assuming C# based on content)
    # Replace ``` with ```csharp for code blocks that appear to be C#
    $lines = $content -split "`n"
    $inCodeBlock = $false
    $newLines = @()
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        if ($line -match '^```$' -and -not $inCodeBlock) {
            # Opening code fence without language
            $inCodeBlock = $true
            # Look ahead to determine if this is likely C# code
            $nextFewLines = $lines[($i+1)..[Math]::Min($i+10, $lines.Count-1)] -join " "
            if ($nextFewLines -match 'class|interface|public|private|namespace|using System') {
                $newLines += '```csharp'
            } else {
                $newLines += '```text'
            }
        } elseif ($line -match '^```' -and $inCodeBlock) {
            # Closing code fence
            $inCodeBlock = $false
            $newLines += $line
        } else {
            $newLines += $line
        }
    }
    
    $content = $newLines -join "`n"
    
    # Fix 3: Remove inline HTML elements
    $content = $content -replace '<([^>]+)>', '`$1`'
    
    # Fix 4: Fix heading increment issues
    # This is complex and file-specific, so we'll handle major cases
    $content = $content -replace '^### (.+)(?=\n\n## )', '## $1'
    
    # Fix 5: Convert fenced code blocks to indented (if required by config)
    # Note: This is commented out as it can be destructive
    # We'll keep fenced blocks but ensure they have languages
    
    # Save the file if changes were made
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "✅ Fixed markdown issues in: $($file.Name)" -ForegroundColor Green
    } else {
        Write-Host "ℹ️ No changes needed for: $($file.Name)" -ForegroundColor Gray
    }
}

Write-Host "`n🎯 Running markdownlint to verify fixes..." -ForegroundColor Cyan

# Run markdownlint on the specific folder
$lintResult = & npx markdownlint-cli2 "$SolidPrinciplesPath\*.md" --config .markdownlint.json 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ All markdown compliance issues resolved!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Some issues remain:" -ForegroundColor Yellow
    Write-Host $lintResult -ForegroundColor White
    Write-Host "`n💡 Manual review may be needed for complex structural issues" -ForegroundColor Cyan
}

Write-Host "`n🔍 Checking link integrity..." -ForegroundColor Cyan

# Check links using Docker
$linkResult = docker run --rm -v "${PWD}:/workspace" -w /workspace lycheeverse/lychee "$SolidPrinciplesPath/*.md" --no-progress 2>&1

if ($linkResult -match "✅.*OK.*🚫.*0.*Errors") {
    Write-Host "✅ All links are working correctly!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Link check results:" -ForegroundColor Yellow
    Write-Host $linkResult -ForegroundColor White
}

Write-Host "`n🎉 SOLID Principles Markdown Compliance Fix Complete!" -ForegroundColor Cyan
Write-Host "📊 Summary: Processed $($MarkdownFiles.Count) files" -ForegroundColor White
Write-Host "🔗 Next: Review remaining issues manually if any" -ForegroundColor Yellow