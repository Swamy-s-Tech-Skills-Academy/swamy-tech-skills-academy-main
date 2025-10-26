# Final SOLID Principles Compliance Fix Script
# Targets remaining issues in SOLID-Principles folder specifically

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

# Focus on SOLID-Principles files only
$SolidFiles = @(
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

$basePath = "01_ReferenceLibrary\01_Development\01_software-design-principles\02_SOLID-Principles"

Write-Host "🎯 Final SOLID Principles Compliance Fix" -ForegroundColor Cyan

foreach ($fileName in $SolidFiles) {
    $filePath = Join-Path $basePath $fileName
    
    if (Test-Path $filePath) {
        Write-Host "📝 Processing: $fileName" -ForegroundColor Green
        
        $content = Get-Content $filePath -Raw -Encoding UTF8
        $originalContent = $content
        
        # Fix remaining fenced code blocks without language
        $lines = $content -split "`r?`n"
        $newLines = @()
        $inCodeBlock = $false
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            
            if ($line -eq '```' -and -not $inCodeBlock) {
                # Opening fence without language
                $inCodeBlock = $true
                $codePreview = ''
                for ($j = $i + 1; $j -lt [Math]::Min($i + 5, $lines.Count); $j++) {
                    $codePreview += $lines[$j] + ' '
                }
                
                # Determine language based on content
                if ($codePreview -match 'class|interface|public|private|using System|namespace') {
                    $newLines += '```csharp'
                } else {
                    $newLines += '```text'
                }
            } else {
                $newLines += $line
                if ($line -match '^```' -and $inCodeBlock) {
                    $inCodeBlock = $false
                }
            }
        }
        
        $content = $newLines -join "`n"
        
        # Fix heading increment issues
        $content = $content -replace '^##### (.+)', '### $1'
        
        # Save if changes were made
        if ($content -ne $originalContent) {
            Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
            Write-Host "✅ Fixed: $fileName" -ForegroundColor Green
        } else {
            Write-Host "ℹ️ No changes: $fileName" -ForegroundColor Gray
        }
    }
}

Write-Host "`n🎯 Verification..." -ForegroundColor Cyan

# Check remaining SOLID-specific errors
$result = npx markdownlint-cli2 "$basePath\*.md" --config .markdownlint.json 2>&1
$solidErrors = $result | Select-String "02_SOLID-Principles" | Where-Object { $_ -notmatch "03_Design-Patterns" }

if ($solidErrors) {
    Write-Host "⚠️ Remaining SOLID issues:" -ForegroundColor Yellow
    $solidErrors | ForEach-Object { Write-Host $_ -ForegroundColor White }
} else {
    Write-Host "🎉 All SOLID Principles compliance issues resolved!" -ForegroundColor Green
}

Write-Host "`n✅ Fix complete!" -ForegroundColor Cyan