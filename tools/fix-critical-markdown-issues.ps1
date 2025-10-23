# Fix Critical Markdown Issues
# Targets specific files that were just corrected for character encoding

$ErrorActionPreference = "Stop"

# Files to fix
$filesToFix = @(
    "01_ReferenceLibrary/01_Development/01_software-design-principles/01_OOP-fundamentals/04_OOP-Advanced-Patterns-PartA.md",
    "01_ReferenceLibrary/01_Development/01_software-design-principles/01_OOP-fundamentals/04_OOP-Advanced-Patterns-PartB.md",
    "01_ReferenceLibrary/01_Development/01_software-design-principles/02_SOLID-Principles/01_SOLID-Part1-Single-Responsibility-PartA.md",
    "01_ReferenceLibrary/01_Development/01_software-design-principles/02_SOLID-Principles/01_SOLID-Part1-Single-Responsibility-PartB.md",
    "01_ReferenceLibrary/01_Development/01_software-design-principles/02_SOLID-Principles/01_SOLID-Part1-Single-Responsibility-PartC.md",
    "01_ReferenceLibrary/01_Development/01_software-design-principles/02_SOLID-Principles/02_SOLID-Part2-Open-Closed-Principle-PartA.md"
)

Write-Host "🔧 Fixing critical markdown issues..." -ForegroundColor Yellow

foreach ($file in $filesToFix) {
    if (Test-Path $file) {
        Write-Host "Processing: $file" -ForegroundColor Cyan
        
        $content = Get-Content $file -Raw -Encoding UTF8
        
        # Fix MD036: Convert "Part X of Y" emphasis to proper headings
        $content = $content -replace '\*\*(Part [A-Z] of \d+)\*\*', '## $1'
        
        # Fix MD001: Adjust heading levels (convert h4 to h3 where appropriate)
        # Look for cases where h4 follows h2 directly
        $content = $content -replace '(?m)^## (.+?)\r?\n\r?\n#### (.+?)$', ('## $1' + "`r`n`r`n" + '### $2')
        
        # Fix MD040: Add language to fenced code blocks
        $content = $content -replace '(?m)^```\s*$', '```csharp'
        
        # Fix MD046: Ensure consistent code block style (prefer fenced)
        # This is complex to fix automatically, but the main issue is mixing styles
        
        # Write back the fixed content
        Set-Content -Path $file -Value $content -Encoding UTF8 -NoNewline
        
        Write-Host "✅ Fixed: $file" -ForegroundColor Green
    } else {
        Write-Host "❌ File not found: $file" -ForegroundColor Red
    }
}

Write-Host "🎯 Running markdownlint to verify fixes..." -ForegroundColor Yellow

# Run markdownlint on just these files to see if issues are resolved
$filePatterns = $filesToFix -join '" "'
$cmd = "npx --yes markdownlint-cli2 `"$filePatterns`" --fix"

try {
    Write-Host "Command: $cmd" -ForegroundColor Gray
    Invoke-Expression $cmd
    Write-Host "✅ Markdown linting completed" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Some linting issues remain: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "🎉 Critical markdown fixes completed!" -ForegroundColor Green