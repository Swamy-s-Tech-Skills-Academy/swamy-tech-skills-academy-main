# Split Oversized STSA Files
# Splits files exceeding 175 lines into properly structured parts
# Created: October 16, 2025

param(
    [string]$FilePath,
    [int]$MaxLines = 175,
    [switch]$WhatIf
)

if (-not $FilePath) {
    Write-Host "Usage: .\split-oversized-file.ps1 -FilePath 'path\to\file.md'" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $FilePath)) {
    Write-Host "File not found: $FilePath" -ForegroundColor Red
    exit 1
}

$lines = Get-Content $FilePath
$totalLines = $lines.Count

Write-Host "=== File Splitter ===" -ForegroundColor Cyan
Write-Host "File: $FilePath" -ForegroundColor Yellow
Write-Host "Total lines: $totalLines" -ForegroundColor Yellow
Write-Host "Max lines per part: $MaxLines" -ForegroundColor Yellow

if ($totalLines -le $MaxLines) {
    Write-Host "File is within size limits. No splitting needed." -ForegroundColor Green
    exit 0
}

$partsNeeded = [Math]::Ceiling($totalLines / $MaxLines)
Write-Host "Parts needed: $partsNeeded" -ForegroundColor Yellow

if ($WhatIf) {
    Write-Host "WHATIF MODE - No changes will be made" -ForegroundColor Magenta
    Write-Host "Would create $partsNeeded parts" -ForegroundColor White
    exit 0
}

# Extract metadata and content
$metadataEnd = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "^---\s*$" -and $i -gt 5) {
        $metadataEnd = $i
        break
    }
}

if ($metadataEnd -eq -1) {
    Write-Host "Warning: Could not find metadata section ending with '---'" -ForegroundColor Yellow
    $metadataEnd = 10  # Default assumption
}

$metadata = $lines[0..$metadataEnd]
$content = $lines[($metadataEnd + 1)..($lines.Count - 1)]

$fileInfo = Get-Item $FilePath
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileInfo.Name)
$directory = $fileInfo.DirectoryName

# Calculate lines per part (reserve space for navigation)
$linesPerPart = $MaxLines - $metadata.Count - 15  # Buffer for navigation and structure

Write-Host "`nSplitting into parts..." -ForegroundColor Green

for ($part = 1; $part -le $partsNeeded; $part++) {
    $partLetter = [char](64 + $part)  # A, B, C...
    $partFileName = "${baseName}-Part${partLetter}.md"
    $partPath = Join-Path $directory $partFileName
    
    $startLine = ($part - 1) * $linesPerPart
    $endLine = [Math]::Min(($part * $linesPerPart) - 1, $content.Count - 1)
    
    Write-Host "  Creating $partFileName (lines $($startLine + 1) to $($endLine + 1))" -ForegroundColor Blue
    
    # Build part content
    $partContent = @()
    
    # Copy metadata but update title
    foreach ($line in $metadata) {
        if ($line -match "^# ") {
            $partContent += "$line - Part $partLetter"
        } elseif ($line -match "\*\*Series\*\*:") {
            $partContent += "**Series**: Part $partLetter of $partsNeeded - $(($line -split ':')[1].Trim())"
        } elseif ($line -match "\*\*Estimated Time\*\*:") {
            $partContent += "**Estimated Time**: 27 minutes (Part $partLetter of $partsNeeded)"
        } else {
            $partContent += $line
        }
    }
    
    # Add part navigation
    $partContent += ""
    $partContent += "**📍 Part $partLetter of $partsNeeded**"
    $partContent += ""
    
    if ($part -gt 1) {
        $prevLetter = [char](63 + $part)  # Previous part
        $partContent += "**Previous**: [Part $prevLetter](${baseName}-Part${prevLetter}.md)"
    }
    
    if ($part -lt $partsNeeded) {
        $nextLetter = [char](65 + $part)  # Next part  
        $partContent += "**Next**: [Part $nextLetter](${baseName}-Part${nextLetter}.md)"
    }
    
    $partContent += ""
    $partContent += "---"
    $partContent += ""
    
    # Add content for this part
    if ($startLine -le $content.Count - 1) {
        $actualEndLine = [Math]::Min($endLine, $content.Count - 1)
        $partContent += $content[$startLine..$actualEndLine]
    }
    
    # Add footer navigation
    $partContent += ""
    $partContent += "---"
    $partContent += ""
    $partContent += "## 🔗 Part Navigation"
    $partContent += ""
    
    for ($navPart = 1; $navPart -le $partsNeeded; $navPart++) {
        $navLetter = [char](64 + $navPart)
        $navFileName = "${baseName}-Part${navLetter}.md"
        if ($navPart -eq $part) {
            $partContent += "- **Part $navLetter**: You are here"
        } else {
            $partContent += "- **Part $navLetter**: [$navFileName]($navFileName)"
        }
    }
    
    # Write part file
    $partContent | Out-File $partPath -Encoding UTF8
    
    # Verify size
    $partLines = (Get-Content $partPath | Measure-Object -Line).Lines
    if ($partLines -gt $MaxLines) {
        Write-Host "    WARNING: Part $partLetter has $partLines lines (exceeds $MaxLines)" -ForegroundColor Yellow
    } else {
        Write-Host "    SUCCESS: Part $partLetter has $partLines lines" -ForegroundColor Green
    }
}

# Rename original file
$originalRenamed = $FilePath -replace "\.md$", "-ORIGINAL.md"
Rename-Item $FilePath $originalRenamed
Write-Host "`nOriginal file renamed to: $(Split-Path $originalRenamed -Leaf)" -ForegroundColor Blue

Write-Host "`n=== Split Complete ===" -ForegroundColor Green
Write-Host "Created $partsNeeded part files" -ForegroundColor White
Write-Host "Original file preserved as: $(Split-Path $originalRenamed -Leaf)" -ForegroundColor White