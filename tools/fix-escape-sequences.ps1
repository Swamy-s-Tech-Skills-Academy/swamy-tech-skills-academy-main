# Fix literal \n escape sequences in markdown files
# Replaces literal \n with actual newlines

param(
    [Parameter(Mandatory=$true)]
    [string]$TargetPath,
    
    [string]$Pattern = "*.md"
)

$ErrorActionPreference = "Stop"

function Fix-EscapeSequences {
    param([string]$FilePath)
    
    try {
        $content = [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8)
        
        # Check if file contains escape sequences
        if ($content -notmatch '\\n') {
            return $false
        }
        
        Write-Host "🔧 Fixing: $(Split-Path $FilePath -Leaf)" -ForegroundColor Yellow
        
        # Replace literal \n with actual newlines
        $fixed = $content -replace '\\n', "`n"
        
        # Write back to file
        [System.IO.File]::WriteAllText($FilePath, $fixed, [System.Text.Encoding]::UTF8)
        
        Write-Host "✅ Fixed: $(Split-Path $FilePath -Leaf)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Error fixing $FilePath : $_" -ForegroundColor Red
        return $false
    }
}

# Get all markdown files
$files = Get-ChildItem -Path $TargetPath -Filter $Pattern -Recurse -File

if ($files.Count -eq 0) {
    Write-Host "❌ No markdown files found in $TargetPath" -ForegroundColor Red
    exit 1
}

Write-Host "🔍 Scanning $($files.Count) files for escape sequence corruption..." -ForegroundColor Cyan

$fixed = 0
$skipped = 0

foreach ($file in $files) {
    if (Fix-EscapeSequences -FilePath $file.FullName) {
        $fixed++
    } else {
        $skipped++
    }
}

Write-Host "`n📊 RESULTS" -ForegroundColor Cyan
Write-Host "=" * 50
Write-Host "Files Fixed: $fixed" -ForegroundColor Green
Write-Host "Files Skipped: $skipped" -ForegroundColor Yellow
Write-Host "=" * 50
