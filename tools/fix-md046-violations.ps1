# Fix MD046 Code Block Style Violations in SOLID-Principles
# This script converts fenced code blocks to indented code blocks where required

param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

$ErrorActionPreference = "Stop"

Write-Host "🔧 Starting MD046 code-block-style fixes for SOLID-Principles..." -ForegroundColor Yellow

# Get all markdown files with MD046 violations
$files = @(
    "01_SOLID-Part1-Single-Responsibility-PartB.md",
    "01_SOLID-Part1-Single-Responsibility-PartC.md",
    "02_SOLID-Part2-Open-Closed-Principle-PartB.md",
    "02_SOLID-Part2-Open-Closed-Principle-PartC.md",
    "03_SOLID-Part3-Liskov-Substitution-Principle-PartB.md",
    "03_SOLID-Part3-Liskov-Substitution-Principle-PartC.md",
    "03_SOLID-Part3-Liskov-Substitution-Principle-PartD.md",
    "04_SOLID-Part4-Interface-Segregation-Principle-PartB.md",
    "04_SOLID-Part4-Interface-Segregation-Principle-PartC.md",
    "04_SOLID-Part4-Interface-Segregation-Principle-PartD.md",
    "04_SOLID-Principles-Deep-Dive-PartB.md",
    "04_SOLID-Principles-Deep-Dive-PartC.md",
    "04_SOLID-Principles-Deep-Dive-PartD.md",
    "04_SOLID-Principles-Deep-Dive-PartE.md",
    "05_SOLID-Part5-Dependency-Inversion-Principle-PartB.md",
    "05_SOLID-Part5-Dependency-Inversion-Principle-PartC.md",
    "05_SOLID-Part5-Dependency-Inversion-Principle-PartD.md"
)

$totalFixed = 0

foreach ($file in $files) {
    $filePath = Join-Path $FolderPath $file
    
    if (Test-Path $filePath) {
        Write-Host "📄 Processing: $file" -ForegroundColor Cyan
        
        $content = Get-Content $filePath -Raw
        $originalContent = $content
        
        # Convert specific fenced code blocks to indented format
        # Pattern: ```text followed by content and closing ```
        $pattern = '```text\r?\n(.*?)\r?\n```'
        
        $matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
        
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
            
            # Replace the fenced block with indented block
            $content = $content.Replace($match.Value, $indentedBlock)
        }
        
        # Only write if changes were made
        if ($content -ne $originalContent) {
            Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
            $changeCount = $matches.Count
            $totalFixed += $changeCount
            Write-Host "  ✅ Fixed $changeCount MD046 violations" -ForegroundColor Green
        } else {
            Write-Host "  ℹ️  No MD046 violations found" -ForegroundColor Blue
        }
    } else {
        Write-Host "  ⚠️  File not found: $file" -ForegroundColor Yellow
    }
}

Write-Host "`n🎯 MD046 Fix Summary:" -ForegroundColor Green
Write-Host "  📁 Folder: $FolderPath" -ForegroundColor White
Write-Host "  📄 Files Processed: $($files.Count)" -ForegroundColor White  
Write-Host "  🔧 Total Violations Fixed: $totalFixed" -ForegroundColor White

if ($totalFixed -gt 0) {
    Write-Host "`n✅ All MD046 code-block-style violations have been fixed!" -ForegroundColor Green
} else {
    Write-Host "`nℹ️  No MD046 violations were found to fix." -ForegroundColor Blue
}