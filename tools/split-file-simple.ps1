# Split Oversized STSA File - Simple Version
param([string]$FilePath, [int]$MaxLines = 175)

if (-not $FilePath -or -not (Test-Path $FilePath)) {
    Write-Host "File not found: $FilePath" -ForegroundColor Red
    exit 1
}

$lines = Get-Content $FilePath
$totalLines = $lines.Count

Write-Host "Splitting file: $FilePath" -ForegroundColor Green  
Write-Host "Total lines: $totalLines" -ForegroundColor Yellow

if ($totalLines -le $MaxLines) {
    Write-Host "File is within size limits" -ForegroundColor Green
    exit 0
}

$partsNeeded = [Math]::Ceiling($totalLines / $MaxLines)
Write-Host "Will create $partsNeeded parts" -ForegroundColor Yellow

# Find metadata end
$metadataEnd = 10
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "^---\s*$" -and $i -gt 5) {
        $metadataEnd = $i
        break
    }
}

$metadata = $lines[0..$metadataEnd]  
$content = $lines[($metadataEnd + 1)..($lines.Count - 1)]

$fileInfo = Get-Item $FilePath
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileInfo.Name)
$directory = $fileInfo.DirectoryName

$linesPerPart = $MaxLines - $metadata.Count - 10

for ($part = 1; $part -le $partsNeeded; $part++) {
    $partLetter = [char](64 + $part)  # A, B, C
    $partFileName = "$baseName-Part$partLetter.md"
    $partPath = Join-Path $directory $partFileName
    
    $startLine = ($part - 1) * $linesPerPart
    $endLine = [Math]::Min(($part * $linesPerPart) - 1, $content.Count - 1)
    
    Write-Host "Creating $partFileName" -ForegroundColor Blue
    
    $partContent = @()
    
    # Copy metadata but update title
    foreach ($line in $metadata) {
        if ($line -match "^# ") {
            $partContent += "$line - Part $partLetter"
        } else {
            $partContent += $line  
        }
    }
    
    $partContent += ""
    $partContent += "**Part $partLetter of $partsNeeded**"
    $partContent += ""
    
    if ($part -gt 1) {
        $prevLetter = [char](63 + $part)
        $prevFile = "$baseName-Part$prevLetter.md"
        $partContent += "Previous: [$prevFile]($prevFile)"
    }
    
    if ($part -lt $partsNeeded) {
        $nextLetter = [char](65 + $part)
        $nextFile = "$baseName-Part$nextLetter.md" 
        $partContent += "Next: [$nextFile]($nextFile)"
    }
    
    $partContent += ""
    $partContent += "---"
    $partContent += ""
    
    # Add content
    if ($startLine -le $content.Count - 1) {
        $actualEnd = [Math]::Min($endLine, $content.Count - 1)
        $partContent += $content[$startLine..$actualEnd]
    }
    
    $partContent | Out-File $partPath -Encoding UTF8
    
    $partLines = (Get-Content $partPath | Measure-Object -Line).Lines
    Write-Host "  Created with $partLines lines" -ForegroundColor Green
}

# Rename original
$originalNew = $FilePath -replace "\.md$", "-ORIGINAL.md"
Rename-Item $FilePath $originalNew
Write-Host "Original renamed to: $(Split-Path $originalNew -Leaf)" -ForegroundColor Blue