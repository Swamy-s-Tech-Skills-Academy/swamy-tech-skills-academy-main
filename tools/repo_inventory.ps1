<#
.SYNOPSIS
  Produce a comprehensive inventory of the repository with full folder tree structure.
.DESCRIPTION
  Generates a detailed folder tree showing parent-child relationships, file counts,
  and repository structure analysis.
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "",
    [Parameter(Mandatory=$false)]
    [switch]$ShowFiles = $false,
    [Parameter(Mandatory=$false)]
    [int]$MaxDepth = 10
)

$ErrorActionPreference = "Stop"

function Get-FolderTree {
    param(
        [string]$Path,
        [string]$Prefix = "",
        [int]$CurrentDepth = 0,
        [int]$MaxDepth = 10,
        [bool]$ShowFiles = $false
    )
    
    if ($CurrentDepth -ge $MaxDepth) { return }
    
    $items = Get-ChildItem -Path $Path -Force -ErrorAction SilentlyContinue | Sort-Object @{Expression={$_.PSIsContainer}; Descending=$true}, Name
    $folders = $items | Where-Object { $_.PSIsContainer }
    $files = $items | Where-Object { -not $_.PSIsContainer }
    
    # Process folders first
    for ($i = 0; $i -lt $folders.Count; $i++) {
        $folder = $folders[$i]
        $isLast = ($i -eq ($folders.Count - 1)) -and (-not $ShowFiles -or $files.Count -eq 0)
        
        $currentPrefix = if ($isLast) { "└── " } else { "├── " }
        $nextPrefix = if ($isLast) { "    " } else { "│   " }
        
        # Get folder statistics
        $fileCount = (Get-ChildItem -Path $folder.FullName -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object).Count
        $subFolderCount = (Get-ChildItem -Path $folder.FullName -Directory -Force -ErrorAction SilentlyContinue | Measure-Object).Count
        
        $folderInfo = "$($folder.Name) ($fileCount files, $subFolderCount folders)"
        Write-Output "$Prefix$currentPrefix$folderInfo"
        
        # Recursively process subfolders
        Get-FolderTree -Path $folder.FullName -Prefix "$Prefix$nextPrefix" -CurrentDepth ($CurrentDepth + 1) -MaxDepth $MaxDepth -ShowFiles $ShowFiles
    }
    
    # Process files if requested
    if ($ShowFiles) {
        for ($i = 0; $i -lt $files.Count; $i++) {
            $file = $files[$i]
            $isLast = ($i -eq ($files.Count - 1))
            
            $currentPrefix = if ($isLast) { "└── " } else { "├── " }
            $fileSize = if ($file.Length -gt 1MB) { "{0:N1} MB" -f ($file.Length / 1MB) } 
                       elseif ($file.Length -gt 1KB) { "{0:N1} KB" -f ($file.Length / 1KB) }
                       else { "$($file.Length) bytes" }
            
            Write-Output "$Prefix$currentPrefix$($file.Name) ($fileSize)"
        }
    }
}

function Get-RepositoryStatistics {
    $stats = @{}
    
    Write-Host "🔍 COMPREHENSIVE REPOSITORY ANALYSIS" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Repository Location: $(Get-Location)" -ForegroundColor Yellow
    Write-Host "Analysis Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow
    Write-Host ""
    
    # Top-level overview
    Write-Host "📊 TOP-LEVEL OVERVIEW" -ForegroundColor Green
    Write-Host "=====================" -ForegroundColor Green
    
    $topFiles = Get-ChildItem -File | Sort-Object Name
    $topFolders = Get-ChildItem -Directory | Sort-Object Name
    
    Write-Host "📁 Root Files ($($topFiles.Count)):" -ForegroundColor White
    $topFiles | ForEach-Object {
        $size = if ($_.Length -gt 1KB) { "{0:N1} KB" -f ($_.Length / 1KB) } else { "$($_.Length) bytes" }
        Write-Host "   • $($_.Name) ($size)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "📂 Root Directories ($($topFolders.Count)):" -ForegroundColor White
    $topFolders | ForEach-Object {
        $fileCount = (Get-ChildItem -Path $_.FullName -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object).Count
        $folderCount = (Get-ChildItem -Path $_.FullName -Recurse -Directory -Force -ErrorAction SilentlyContinue | Measure-Object).Count
        Write-Host "   • $($_.Name)/ ($fileCount files, $folderCount subfolders)" -ForegroundColor Gray
    }
    
    return @{
        TopFiles = $topFiles.Count
        TopFolders = $topFolders.Count
        TotalFiles = (Get-ChildItem -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object).Count
        TotalFolders = (Get-ChildItem -Recurse -Directory -Force -ErrorAction SilentlyContinue | Measure-Object).Count
    }
}

# Main execution
Write-Host ""
$stats = Get-RepositoryStatistics

Write-Host ""
Write-Host "🌳 COMPLETE FOLDER TREE STRUCTURE" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Generate the tree structure
$treeOutput = @()
$treeOutput += "Repository Root: $(Split-Path -Leaf (Get-Location))"
$treeOutput += Get-FolderTree -Path "." -MaxDepth $MaxDepth -ShowFiles $ShowFiles

# Display the tree
$treeOutput | ForEach-Object { Write-Host $_ -ForegroundColor White }

Write-Host ""
Write-Host "📈 REPOSITORY STATISTICS SUMMARY" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Total Files: $($stats.TotalFiles)" -ForegroundColor Yellow
Write-Host "Total Folders: $($stats.TotalFolders)" -ForegroundColor Yellow
Write-Host "Root Files: $($stats.TopFiles)" -ForegroundColor Yellow  
Write-Host "Root Directories: $($stats.TopFolders)" -ForegroundColor Yellow

# Save to file if requested
if ($OutputFile) {
    Write-Host ""
    Write-Host "💾 Saving tree structure to: $OutputFile" -ForegroundColor Green
    $treeOutput | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Host "✅ Tree structure saved successfully!" -ForegroundColor Green
}

Write-Host ""
Write-Host "🚀 ANALYSIS COMPLETE" -ForegroundColor Green
