# Fix References After OOP-Fundamentals Renaming
# Updates all internal references to use the new standardized filenames

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

$ErrorActionPreference = "Stop"

Write-Host "🔗 Fixing Internal References After Renaming" -ForegroundColor Cyan
Write-Host "Target Folder: $FolderPath" -ForegroundColor Yellow

# Define the reference mappings
$ReferenceMap = @{
    "01A1_OOP-Core-Concepts" = "01_OOP-Core-Concepts-PartA"
    "01A2_OOP-Classes-Blueprint" = "01_OOP-Core-Concepts-PartB"
    "01B1_OOP-Objects-Creation" = "01_OOP-Objects-Creation-PartA"
    "01B2_OOP-Objects-Practice" = "01_OOP-Objects-Creation-PartB"
}

# Get all markdown files in the folder
$allMdFiles = Get-ChildItem -Path $FolderPath -Filter "*.md"

Write-Host "`n📝 Updating references in $($allMdFiles.Count) files..." -ForegroundColor Green

$updatedFiles = @()
foreach ($file in $allMdFiles) {
    Write-Host "  Processing: $($file.Name)" -ForegroundColor White
    
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fileUpdated = $false
    
    foreach ($oldRef in $ReferenceMap.Keys) {
        $newRef = $ReferenceMap[$oldRef]
        
        # Update markdown links: [text](oldref) -> [text](newref)
        $oldLinkPattern = "\[([^\]]*)\]\($oldRef\)"
        $newLinkReplacement = "[$1]($newRef)"
        if ($content -match $oldLinkPattern) {
            $content = $content -replace $oldLinkPattern, $newLinkReplacement
            $fileUpdated = $true
            Write-Host "    ✓ Updated markdown link: $oldRef → $newRef" -ForegroundColor Green
        }
        
        # Update direct filename references in text
        if ($content -match $oldRef -and $content -notmatch "\[([^\]]*)\]\($oldRef\)") {
            $content = $content -replace $oldRef, $newRef
            $fileUpdated = $true
            Write-Host "    ✓ Updated text reference: $oldRef → $newRef" -ForegroundColor Green
        }
    }
    
    if ($fileUpdated) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        $updatedFiles += $file.Name
        Write-Host "    ✅ File updated successfully" -ForegroundColor Green
    } else {
        Write-Host "    • No references to update" -ForegroundColor Gray
    }
}

Write-Host "`n🎉 Reference Updates Complete!" -ForegroundColor Green
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "  • Files processed: $($allMdFiles.Count)" -ForegroundColor White
Write-Host "  • Files updated: $($updatedFiles.Count)" -ForegroundColor White

if ($updatedFiles.Count -gt 0) {
    Write-Host "`n📝 Updated Files:" -ForegroundColor Cyan
    foreach ($file in $updatedFiles) {
        Write-Host "  • $file" -ForegroundColor White
    }
}

Write-Host "`n✅ All internal references now use standardized filenames!" -ForegroundColor Green