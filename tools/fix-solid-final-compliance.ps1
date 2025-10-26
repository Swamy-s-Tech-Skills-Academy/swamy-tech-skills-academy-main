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
Write-Host "🔍 Targeting specific markdown violations..." -ForegroundColor Yellow

foreach ($fileName in $SolidFiles) {
    $filePath = Join-Path $basePath $fileName
    
    if (Test-Path $filePath) {
        Write-Host "`n📝 Processing: $fileName" -ForegroundColor Green
        
        $content = Get-Content $filePath -Raw -Encoding UTF8
        $originalContent = $content
        
        # Fix remaining fenced code blocks without language
        $lines = $content -split "`r?`n"
        $newLines = @()
        $inCodeBlock = $false
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            
            if ($line -eq "```" -and -not $inCodeBlock) {
                # Opening fence without language - analyze next few lines
                $inCodeBlock = $true
                $codePreview = ""
                for ($j = $i + 1; $j -lt [Math]::Min($i + 5, $lines.Count); $j++) {
                    $codePreview += $lines[$j] + " "
                }
                
                # Determine language based on content
                if ($codePreview -match 'class\s+\w+|interface\s+\w+|public\s+|private\s+|using\s+System|namespace\s+') {
                    $newLines += "```csharp"
                } elseif ($codePreview -match '^(\s*-|\s*\*|\s*\+|\s*\w+:)') {
                    $newLines += "```text"
                } else {
                    $newLines += "```csharp"  # Default to C# for SOLID principles
                }
            } else {
                $newLines += $line
                if ($line -match "^```" -and $inCodeBlock) {
                    $inCodeBlock = $false
                }
            }
        }
        
        $content = $newLines -join "`n"
        
        # Fix heading increment issues - convert h5 to h3 when appropriate
        $content = $content -replace '^##### (.+)', '### $1'
        
        # Fix h4 to h3 when it follows h2
        $lines = $content -split "`n"
        $newLines = @()
        $previousHeadingLevel = 0
        
        foreach ($line in $lines) {
            if ($line -match '^(#{1,6})\s+(.+)') {
                $currentLevel = $matches[1].Length
                $headingText = $matches[2]
                
                # If jumping from h2 to h4, make it h3
                if ($previousHeadingLevel -eq 2 -and $currentLevel -eq 4) {
                    $newLines += "### $headingText"
                    $previousHeadingLevel = 3
                } else {
                    $newLines += $line
                    $previousHeadingLevel = $currentLevel
                }
            } else {
                $newLines += $line
            }
        }
        
        $content = $newLines -join "`n"
        
        # Save if changes were made
        if ($content -ne $originalContent) {
            Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
            Write-Host "✅ Fixed compliance issues in: $fileName" -ForegroundColor Green
        } else {
            Write-Host "ℹ️ No changes needed for: $fileName" -ForegroundColor Gray
        }
    } else {
        Write-Host "⚠️ File not found: $fileName" -ForegroundColor Yellow
    }
}

Write-Host "`n🎯 Final verification..." -ForegroundColor Cyan

# Check only SOLID-Principles specific errors
$solidLintResult = npx markdownlint-cli2 "$basePath\*.md" --config .markdownlint.json 2>&1 | Select-String "02_SOLID-Principles" | Where-Object { $_ -notmatch "03_Design-Patterns" }

$errorCount = ($solidLintResult | Measure-Object).Count

if ($errorCount -eq 0) {
    Write-Host "🎉 All SOLID Principles markdown compliance issues resolved!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Remaining issues in SOLID-Principles: $errorCount" -ForegroundColor Yellow
    $solidLintResult | ForEach-Object { Write-Host $_ -ForegroundColor White }
}

Write-Host "`n✅ SOLID Principles compliance fix complete!" -ForegroundColor Cyan