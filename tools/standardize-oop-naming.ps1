# OOP-Fundamentals Naming Convention Standardization Script
# Renames inconsistent files to STSA standard format and updates all internal references

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath,
    [switch]$WhatIf = $false
)

$ErrorActionPreference = "Stop"

Write-Host "🔧 OOP-Fundamentals Naming Standardization Script" -ForegroundColor Cyan
Write-Host "Target Folder: $FolderPath" -ForegroundColor Yellow

# Define the file renames based on STSA conventions
$RenameMap = @{
    "01A1_OOP-Core-Concepts.md" = "01_OOP-Core-Concepts-PartA.md"
    "01A2_OOP-Classes-Blueprint.md" = "01_OOP-Core-Concepts-PartB.md"
    "01B1_OOP-Objects-Creation.md" = "01_OOP-Objects-Creation-PartA.md"
    "01B2_OOP-Objects-Practice.md" = "01_OOP-Objects-Creation-PartB.md"
}

# Verify folder exists
if (-not (Test-Path $FolderPath)) {
    Write-Error "Folder not found: $FolderPath"
    exit 1
}

Write-Host "`n📋 Planned File Renames:" -ForegroundColor Green
foreach ($oldName in $RenameMap.Keys) {
    $newName = $RenameMap[$oldName]
    $oldPath = Join-Path $FolderPath $oldName
    $newPath = Join-Path $FolderPath $newName
    
    if (Test-Path $oldPath) {
        Write-Host "  ✓ $oldName → $newName" -ForegroundColor White
    } else {
        Write-Host "  ⚠ $oldName (file not found)" -ForegroundColor Yellow
    }
}

# Get all markdown files in the folder for reference updates
$allMdFiles = Get-ChildItem -Path $FolderPath -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }

Write-Host "`n🔍 Files that will have references updated:" -ForegroundColor Green
foreach ($file in $allMdFiles) {
    Write-Host "  • $($file.Name)" -ForegroundColor White
}

if ($WhatIf) {
    Write-Host "`n🔍 WHAT-IF MODE: No changes will be made" -ForegroundColor Yellow
    
    # Show what references would be updated
    Write-Host "`n📝 Reference Updates Analysis:" -ForegroundColor Green
    
    foreach ($file in $allMdFiles) {
        $content = Get-Content $file.FullName -Raw
        $hasReferences = $false
        
        foreach ($oldName in $RenameMap.Keys) {
            $oldNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($oldName)
            if ($content -match $oldNameWithoutExt) {
                if (-not $hasReferences) {
                    Write-Host "`n  In file: $($file.Name)" -ForegroundColor Cyan
                    $hasReferences = $true
                }
                $newName = $RenameMap[$oldName]
                $newNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($newName)
                Write-Host "    • $oldNameWithoutExt → $newNameWithoutExt" -ForegroundColor White
            }
        }
    }
    
    Write-Host "`nRun without -WhatIf to execute the changes." -ForegroundColor Yellow
    return
}

# Confirm before proceeding
Write-Host "`n⚠️  This will rename files and update all internal references." -ForegroundColor Yellow
$confirmation = Read-Host "Continue? (y/N)"
if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
    Write-Host "Operation cancelled." -ForegroundColor Red
    return
}

Write-Host "`n🚀 Starting file renames..." -ForegroundColor Green

# Step 1: Rename files
$renamedFiles = @()
foreach ($oldName in $RenameMap.Keys) {
    $newName = $RenameMap[$oldName]
    $oldPath = Join-Path $FolderPath $oldName
    $newPath = Join-Path $FolderPath $newName
    
    if (Test-Path $oldPath) {
        try {
            Rename-Item -Path $oldPath -NewName $newName -Force
            Write-Host "  ✅ Renamed: $oldName → $newName" -ForegroundColor Green
            $renamedFiles += @{ Old = $oldName; New = $newName }
        }
        catch {
            Write-Error "Failed to rename $oldName to $newName`: $($_.Exception.Message)"
        }
    } else {
        Write-Host "  ⚠️  File not found: $oldName" -ForegroundColor Yellow
    }
}

Write-Host "`n📝 Updating internal references..." -ForegroundColor Green

# Step 2: Update references in all files
$updatedFiles = @()
foreach ($file in $allMdFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fileUpdated = $false
    
    foreach ($oldName in $RenameMap.Keys) {
        $newName = $RenameMap[$oldName]
        $oldNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($oldName)
        $newNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($newName)
        
        # Update markdown links
        $oldLinkPattern = "\[([^\]]*)\]\($oldNameWithoutExt\)"
        $newLinkReplacement = "[$1]($newNameWithoutExt)"
        if ($content -match $oldLinkPattern) {
            $content = $content -replace $oldLinkPattern, $newLinkReplacement
            $fileUpdated = $true
        }
        
        # Update direct filename references
        if ($content -match $oldNameWithoutExt) {
            $content = $content -replace $oldNameWithoutExt, $newNameWithoutExt
            $fileUpdated = $true
        }
    }
    
    if ($fileUpdated) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "  ✅ Updated references in: $($file.Name)" -ForegroundColor Green
        $updatedFiles += $file.Name
    }
}

Write-Host "`n🎉 Standardization Complete!" -ForegroundColor Green
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "  • Files renamed: $($renamedFiles.Count)" -ForegroundColor White
Write-Host "  • Files with updated references: $($updatedFiles.Count)" -ForegroundColor White

if ($renamedFiles.Count -gt 0) {
    Write-Host "`n📋 Renamed Files:" -ForegroundColor Cyan
    foreach ($rename in $renamedFiles) {
        Write-Host "  • $($rename.Old) → $($rename.New)" -ForegroundColor White
    }
}

if ($updatedFiles.Count -gt 0) {
    Write-Host "`n📝 Files with Updated References:" -ForegroundColor Cyan
    foreach ($file in $updatedFiles) {
        Write-Host "  • $file" -ForegroundColor White
    }
}

Write-Host "`n✅ STSA naming conventions now applied consistently!" -ForegroundColor Green
Write-Host "📁 Next: Run markdown lint check to verify compliance" -ForegroundColor Yellow