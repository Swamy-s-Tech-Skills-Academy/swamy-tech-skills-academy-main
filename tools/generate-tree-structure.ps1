# Generate Comprehensive Repository Tree Structure
# Creates a detailed folder tree showing parent-child relationships

param(
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "tools\repo-structure.txt",
    [Parameter(Mandatory=$false)]
    [switch]$IncludeFiles = $false
)

$ErrorActionPreference = "Stop"

Write-Host "🌳 Generating comprehensive repository tree structure..." -ForegroundColor Cyan

# Function to generate tree structure
function Get-TreeStructure {
    param(
        [string]$Path = ".",
        [string]$Prefix = "",
        [bool]$IsLast = $true,
        [bool]$IncludeFiles = $false
    )
    
    $items = Get-ChildItem -Path $Path | Sort-Object @{Expression={$_.PSIsContainer}; Descending=$true}, Name
    
    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        $isLastItem = ($i -eq ($items.Count - 1))
        
        # Determine the tree symbols
        if ($isLastItem) {
            $currentPrefix = "└── "
            $nextPrefix = $Prefix + "    "
        } else {
            $currentPrefix = "├── "
            $nextPrefix = $Prefix + "│   "
        }
        
        # Output current item
        if ($item.PSIsContainer) {
            "$Prefix$currentPrefix$($item.Name)/"
            # Recurse into subdirectory
            Get-TreeStructure -Path $item.FullName -Prefix $nextPrefix -IncludeFiles $IncludeFiles
        } elseif ($IncludeFiles) {
            "$Prefix$currentPrefix$($item.Name)"
        }
    }
}

# Generate the tree structure
$treeOutput = @()
$treeOutput += "# STSA Repository Complete Folder Structure"
$treeOutput += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$treeOutput += "Repository: swamy-tech-skills-academy-main"
$treeOutput += "Branch: swamy/26oct-work"
$treeOutput += ""
$treeOutput += "## Root Directory Structure"
$treeOutput += ""
$treeOutput += "swamy-tech-skills-academy-main/"

# Get the tree structure
$structure = Get-TreeStructure -IncludeFiles $IncludeFiles

# Add structure to output
$treeOutput += $structure

# Add statistics
$treeOutput += ""
$treeOutput += "## Repository Statistics"
$treeOutput += ""

# Count directories and files
$totalDirs = (Get-ChildItem -Recurse -Directory).Count
$totalFiles = (Get-ChildItem -Recurse -File).Count
$totalSize = (Get-ChildItem -Recurse -File | Measure-Object -Property Length -Sum).Sum

$treeOutput += "- Total Directories: $totalDirs"
$treeOutput += "- Total Files: $totalFiles"
$treeOutput += "- Total Size: $([math]::Round($totalSize / 1MB, 2)) MB"

# Get top-level folder breakdown
$treeOutput += ""
$treeOutput += "## Top-Level Directory Breakdown"
$treeOutput += ""

$topLevelDirs = Get-ChildItem -Directory | Sort-Object Name
foreach ($dir in $topLevelDirs) {
    $dirFiles = (Get-ChildItem -Path $dir.FullName -Recurse -File).Count
    $dirDirs = (Get-ChildItem -Path $dir.FullName -Recurse -Directory).Count
    $dirSize = (Get-ChildItem -Path $dir.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum
    
    $treeOutput += "### $($dir.Name)/"
    $treeOutput += "- Files: $dirFiles"
    $treeOutput += "- Subdirectories: $dirDirs"
    $treeOutput += "- Size: $([math]::Round($dirSize / 1MB, 2)) MB"
    $treeOutput += ""
}

# Write to file
$treeOutput | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "✅ Repository tree structure saved to: $OutputFile" -ForegroundColor Green
Write-Host "📊 Statistics:" -ForegroundColor Yellow
Write-Host "   - Total Directories: $totalDirs" -ForegroundColor White
Write-Host "   - Total Files: $totalFiles" -ForegroundColor White
Write-Host "   - Total Size: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor White