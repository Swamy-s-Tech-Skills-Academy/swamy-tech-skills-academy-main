#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Comprehensive STSA folder compliance fixer
.DESCRIPTION
    Fixes character encoding, splits oversized files, and verifies compliance for any folder
.PARAMETER FolderPath
    Path to folder to fix (relative to repo root)
.EXAMPLE
    .\fix-folder-compliance.ps1 -FolderPath "01_ReferenceLibrary\01_Development\01_software-design-principles\02_SOLID-Principles"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

$ErrorActionPreference = "Stop"

Write-Host "=== STSA Folder Compliance Fixer ===" -ForegroundColor Cyan
Write-Host "Target: $FolderPath" -ForegroundColor Yellow

# Step 1: Fix Character Encoding
Write-Host "`n--- Step 1: Fixing Character Encoding ---" -ForegroundColor Green
$mdFiles = Get-ChildItem "$FolderPath\*.md" -ErrorAction SilentlyContinue
if ($mdFiles) {
    foreach ($file in $mdFiles) {
        try {
            $content = Get-Content $file.FullName -Raw -Encoding UTF8
            $originalLength = $content.Length
            
            # Remove replacement characters and problematic Unicode
            $fixed = $content -replace '�', '' -replace '🎯', '## ' -replace '✅', '[x]' -replace '❌', '[ ]'
            
            if ($fixed.Length -ne $originalLength) {
                Set-Content $file.FullName -Value $fixed -Encoding UTF8
                Write-Host "  Fixed encoding: $($file.Name)" -ForegroundColor Yellow
            } else {
                Write-Host "  Clean: $($file.Name)" -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "  Error fixing $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  No markdown files found" -ForegroundColor Gray
}

# Step 2: Split Oversized Files
Write-Host "`n--- Step 2: Splitting Oversized Files ---" -ForegroundColor Green
$mdFiles = Get-ChildItem "$FolderPath\*.md" -ErrorAction SilentlyContinue
$oversizedFiles = @()

foreach ($file in $mdFiles) {
    $content = Get-Content $file.FullName
    $lineCount = $content.Count
    
    if ($lineCount -gt 175) {
        $oversizedFiles += $file
        Write-Host "  Found oversized: $($file.Name) ($lineCount lines)" -ForegroundColor Yellow
    }
}

if ($oversizedFiles.Count -gt 0) {
    Write-Host "  Splitting $($oversizedFiles.Count) oversized files..." -ForegroundColor Yellow
    
    foreach ($file in $oversizedFiles) {
        try {
            Write-Host "    Splitting: $($file.Name)" -ForegroundColor Gray
            & "$PSScriptRoot\split-file-simple.ps1" -FilePath $file.FullName
            
            # Remove original after successful split
            if (Test-Path "$($file.DirectoryName)\$($file.BaseName)-PartA.md") {
                Remove-Item $file.FullName -Force
                Write-Host "    ✓ Split and cleaned: $($file.Name)" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "    ✗ Failed to split: $($file.Name) - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  No oversized files found" -ForegroundColor Gray
}

# Step 3: Final Compliance Check
Write-Host "`n--- Step 3: Final Compliance Verification ---" -ForegroundColor Green
$mdFiles = Get-ChildItem "$FolderPath\*.md" -ErrorAction SilentlyContinue
$compliant = 0
$total = 0

foreach ($file in $mdFiles) {
    $content = Get-Content $file.FullName
    $lines = $content.Count
    $total++
    
    $encodingOK = -not ((Get-Content $file.FullName -Raw) -match '�')
    $sizeOK = $lines -le 175
    
    if ($sizeOK -and $encodingOK) {
        $compliant++
        Write-Host "  ✓ $($file.Name): $lines lines" -ForegroundColor Green
    } elseif (-not $sizeOK) {
        Write-Host "  ✗ $($file.Name): $lines lines (OVERSIZED)" -ForegroundColor Red
    } else {
        Write-Host "  ⚠ $($file.Name): $lines lines (ENCODING ISSUES)" -ForegroundColor Yellow
    }
}

$complianceRate = if ($total -gt 0) { [math]::Round($compliant/$total*100) } else { 100 }

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Files processed: $total" -ForegroundColor White
Write-Host "Compliant files: $compliant" -ForegroundColor Green
Write-Host "Compliance rate: $complianceRate%" -ForegroundColor $(if ($complianceRate -eq 100) { "Green" } elseif ($complianceRate -ge 80) { "Yellow" } else { "Red" })

if ($complianceRate -eq 100) {
    Write-Host "`n🎉 FOLDER IS FULLY COMPLIANT!" -ForegroundColor Green
} else {
    Write-Host "`n⚠️  FOLDER NEEDS ADDITIONAL WORK" -ForegroundColor Yellow
}