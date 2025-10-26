param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

$ErrorActionPreference = "Stop"

Write-Host "Starting MD046 fix for remaining violations..." -ForegroundColor Green

# Array of files with specific line numbers that need fixing based on the markdownlint output
$FilesToFix = @(
    @{File="01_SOLID-Part1-Single-Responsibility-PartB.md"; Line=70},
    @{File="01_SOLID-Part1-Single-Responsibility-PartC.md"; Line=31},
    @{File="02_SOLID-Part2-Open-Closed-Principle-PartC.md"; Line=135},
    @{File="03_SOLID-Part3-Liskov-Substitution-Principle-PartD.md"; Line=122},
    @{File="04_SOLID-Part4-Interface-Segregation-Principle-PartB.md"; Line=140},
    @{File="04_SOLID-Part4-Interface-Segregation-Principle-PartD.md"; Line=36},
    @{File="04_SOLID-Principles-Deep-Dive-PartC.md"; Line=155},
    @{File="04_SOLID-Principles-Deep-Dive-PartE.md"; Line=170}
)

foreach ($item in $FilesToFix) {
    $filePath = Join-Path $FolderPath $item.File
    
    if (Test-Path $filePath) {
        Write-Host "Processing: $($item.File)" -ForegroundColor Yellow
        
        $content = Get-Content $filePath -Raw
        $lines = $content -split "`n"
        
        # Check if the specified line contains a fenced code block
        $lineIndex = $item.Line - 1
        if ($lineIndex -lt $lines.Count -and $lines[$lineIndex] -match '^\s*```') {
            Write-Host "  Found fenced block at line $($item.Line)" -ForegroundColor Cyan
            
            # Find the end of this code block
            $endIndex = -1
            for ($i = $lineIndex + 1; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match '^\s*```\s*$') {
                    $endIndex = $i
                    break
                }
            }
            
            if ($endIndex -gt $lineIndex) {
                # Replace fenced block with indented block
                $newLines = @()
                
                # Add content before the code block
                if ($lineIndex -gt 0) {
                    $newLines += $lines[0..($lineIndex-1)]
                }
                
                # Convert the code block content (skip opening and closing ```)
                for ($i = $lineIndex + 1; $i -lt $endIndex; $i++) {
                    $newLines += "    " + $lines[$i]
                }
                
                # Add content after the code block
                if ($endIndex + 1 -lt $lines.Count) {
                    $newLines += $lines[($endIndex+1)..($lines.Count-1)]
                }
                
                # Write back to file
                $newContent = $newLines -join "`n"
                Set-Content -Path $filePath -Value $newContent -NoNewline -Encoding UTF8
                Write-Host "  ✅ Fixed MD046 violation at line $($item.Line)" -ForegroundColor Green
            }
        }
        else {
            Write-Host "  ⚠️ No fenced block found at line $($item.Line)" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "  ❌ File not found: $($item.File)" -ForegroundColor Red
    }
}

Write-Host "`n✅ MD046 fix completed!" -ForegroundColor Green
Write-Host "Run markdownlint to verify the fixes..." -ForegroundColor Cyan