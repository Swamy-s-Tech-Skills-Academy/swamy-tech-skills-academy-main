# Fix MD012 violations in newly updated files
# Remove the double blank line that was introduced during metadata addition

param(
    [Parameter(Mandatory=$false)]
    [string]$FolderPath = "01_ReferenceLibrary\01_Development\01_software-design-principles\02_SOLID-Principles"
)

$ErrorActionPreference = "Stop"

Write-Host "🔧 Fixing MD012 violations in Deep-Dive files" -ForegroundColor Yellow

$filesToFix = @(
    "04_SOLID-Principles-Deep-Dive-PartA.md",
    "04_SOLID-Principles-Deep-Dive-PartB.md", 
    "04_SOLID-Principles-Deep-Dive-PartC.md",
    "04_SOLID-Principles-Deep-Dive-PartD.md",
    "04_SOLID-Principles-Deep-Dive-PartE.md",
    "04_SOLID-Principles-Deep-Dive-PartF.md"
)

$totalFixed = 0

foreach ($fileName in $filesToFix) {
    $filePath = Join-Path $FolderPath $fileName
    
    if (Test-Path $filePath) {
        Write-Host "🔧 Processing: $fileName" -ForegroundColor Cyan
        
        $content = Get-Content $filePath -Raw
        $originalContent = $content
        
        # Fix the specific issue: double blank line at end of metadata block (around line 16)
        # Replace patterns where we have metadata followed by double blank line
        $content = $content -replace "- ([^`n]+)`n`n`n([^#])", '- $1

$2'
        
        # Also fix any other multiple consecutive blank lines
        while ($content -match "`n`n`n+") {
            $content = $content -replace "`n`n`n+", "`n`n"
        }
        
        if ($content -ne $originalContent) {
            $content | Set-Content $filePath -NoNewline
            Write-Host "  ✅ Fixed MD012 violations in $fileName" -ForegroundColor Green
            $totalFixed++
        } else {
            Write-Host "  ✨ $fileName already clean" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ❌ File not found: $fileName" -ForegroundColor Red
    }
}

Write-Host "`n🎉 MD012 FIX SUMMARY:" -ForegroundColor Yellow
Write-Host "📁 Files fixed: $totalFixed of $($filesToFix.Count)" -ForegroundColor Green

# Final verification of these specific files
Write-Host "`n🔍 Final verification..." -ForegroundColor Cyan
$violations = npx markdownlint-cli2 "$FolderPath\04_SOLID-Principles-Deep-Dive-Part*.md" --config .markdownlint.json 2>&1 | Where-Object { $_ -match "MD012" -and $_ -match "04_SOLID-Principles-Deep-Dive" }

if ($violations) {
    Write-Host "⚠️ Remaining MD012 violations:" -ForegroundColor Yellow
    $violations | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
} else {
    Write-Host "🏆 ALL MD012 VIOLATIONS FIXED!" -ForegroundColor Green
}