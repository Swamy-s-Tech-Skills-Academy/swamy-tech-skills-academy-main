# Fix Lead Architect Learning Markdown Issues
# Addresses MD040 (code-language), MD035 (hr-style)

param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

Write-Host "Lead Architect Learning Markdown Formatter" -ForegroundColor Cyan
Write-Host "Target: $FolderPath" -ForegroundColor Yellow
if ($DryRun) {
    Write-Host "Mode: DRY RUN (Preview Only)" -ForegroundColor Yellow
} else {
    Write-Host "Mode: APPLY FIXES" -ForegroundColor Green
}
Write-Host ""

# Counters
$filesProcessed = 0
$issuesFixed = 0
$errors = @()

# Get all markdown files
$markdownFiles = Get-ChildItem -Path $FolderPath -Recurse -Filter "*.md" | Where-Object { $_.Name -notlike ".*" }

Write-Host "Found $($markdownFiles.Count) markdown files to process" -ForegroundColor Green
Write-Host ""

foreach ($file in $markdownFiles) {
    $filesProcessed++
    $relativePath = $file.FullName.Replace((Get-Location).Path, "").TrimStart('\')
    
    Write-Host "[$filesProcessed/$($markdownFiles.Count)] Processing: $relativePath" -ForegroundColor Cyan
    
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $originalContent = $content
        $fileIssuesFixed = 0
        
        # Fix MD040: Add language to fenced code blocks
        $codeBlockPattern = '```\s*\n'
        $codeBlockMatches = [regex]::Matches($content, $codeBlockPattern)
        if ($codeBlockMatches.Count -gt 0) {
            $content = $content -replace $codeBlockPattern, "``````text`n"
            $fileIssuesFixed += $codeBlockMatches.Count
            Write-Host "  Fixed $($codeBlockMatches.Count) code blocks (MD040)" -ForegroundColor Green
        }
        
        # Fix MD035: Horizontal rule style (standardize to ---)
        $hrPattern = '^-{4,}$'
        $lines = $content -split "`n"
        $hrFixed = 0
        for ($i = 0; $i -lt $lines.Length; $i++) {
            if ($lines[$i] -match $hrPattern -and $lines[$i] -ne '---') {
                $lines[$i] = '---'
                $hrFixed++
            }
        }
        if ($hrFixed -gt 0) {
            $content = $lines -join "`n"
            $fileIssuesFixed += $hrFixed
            Write-Host "  Fixed $hrFixed horizontal rules (MD035)" -ForegroundColor Green
        }
        
        # Apply changes if not dry run and content changed
        if (-not $DryRun -and $content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            Write-Host "  Changes applied to file" -ForegroundColor Green
        }
        
        if ($fileIssuesFixed -gt 0) {
            Write-Host "  Total issues fixed in file: $fileIssuesFixed" -ForegroundColor Magenta
            $issuesFixed += $fileIssuesFixed
        } else {
            Write-Host "  No issues found" -ForegroundColor DarkGreen
        }
        
    } catch {
        $errorMsg = "Error processing $($file.Name): $($_.Exception.Message)"
        $errors += $errorMsg
        Write-Host "  Error: $errorMsg" -ForegroundColor Red
    }
    
    Write-Host ""
}

# Summary
Write-Host "FORMATTING SUMMARY" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host "Files processed: $filesProcessed" -ForegroundColor White
Write-Host "Issues fixed: $issuesFixed" -ForegroundColor Green
if ($errors.Count -eq 0) {
    Write-Host "Errors: $($errors.Count)" -ForegroundColor Green
} else {
    Write-Host "Errors: $($errors.Count)" -ForegroundColor Red
}

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "ERRORS ENCOUNTERED:" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  $error" -ForegroundColor Red
    }
}

if ($DryRun) {
    Write-Host ""
    Write-Host "DRY RUN COMPLETE - No files were modified" -ForegroundColor Yellow
    Write-Host "Run without -DryRun to apply fixes" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "FORMATTING COMPLETE" -ForegroundColor Green
    Write-Host "Run markdownlint again to verify fixes" -ForegroundColor Cyan
}