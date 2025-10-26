# Comprehensive Repository Structure Analysis
# Phase 1: Deep-Dive Verification of Content Quality

Write-Host "🔍 COMPREHENSIVE REPOSITORY ANALYSIS - Phase 1" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Analyzing folder structure and file inventory..." -ForegroundColor Cyan
Write-Host ""

# Target folders for verification
$TargetFolders = @(
    "01_ReferenceLibrary",
    "02_LeadArchitect-Learning"
)

$TotalResults = @()

foreach ($Folder in $TargetFolders) {
    if (Test-Path $Folder) {
        Write-Host "📁 ANALYZING: $Folder" -ForegroundColor Yellow
        Write-Host "========================" -ForegroundColor Yellow
        
        # Get all files recursively
        $AllFiles = Get-ChildItem -Path $Folder -File -Recurse
        $MarkdownFiles = $AllFiles | Where-Object { $_.Extension -eq ".md" }
        $OtherFiles = $AllFiles | Where-Object { $_.Extension -ne ".md" }
        
        Write-Host "   📚 Total Files: $($AllFiles.Count)" -ForegroundColor White
        Write-Host "   📝 Markdown Files: $($MarkdownFiles.Count)" -ForegroundColor White
        Write-Host "   📄 Other Files: $($OtherFiles.Count)" -ForegroundColor White
        
        # Analyze subdirectory structure
        $Subdirs = Get-ChildItem -Path $Folder -Directory -Recurse
        Write-Host "   📂 Subdirectories: $($Subdirs.Count)" -ForegroundColor White
        
        # File size analysis
        $TotalSize = ($AllFiles | Measure-Object -Property Length -Sum).Sum
        $AvgSize = if ($AllFiles.Count -gt 0) { [math]::Round($TotalSize / $AllFiles.Count / 1KB, 2) } else { 0 }
        Write-Host "   📏 Total Size: $([math]::Round($TotalSize / 1MB, 2)) MB" -ForegroundColor White
        Write-Host "   📐 Average File Size: $AvgSize KB" -ForegroundColor White
        
        # Top-level structure
        $TopLevel = Get-ChildItem -Path $Folder -Directory | Select-Object -First 10
        Write-Host "   🏗️  Top-level directories:" -ForegroundColor Cyan
        foreach ($Dir in $TopLevel) {
            $FileCount = (Get-ChildItem -Path $Dir.FullName -File -Recurse).Count
            Write-Host "      • $($Dir.Name) ($FileCount files)" -ForegroundColor Gray
        }
        
        # File extension breakdown
        $Extensions = $AllFiles | Group-Object Extension | Sort-Object Count -Descending
        Write-Host "   📋 File types:" -ForegroundColor Cyan
        foreach ($Ext in $Extensions) {
            Write-Host "      • $($Ext.Name): $($Ext.Count) files" -ForegroundColor Gray
        }
        
        Write-Host ""
        
        # Store results for summary
        $FolderResult = [PSCustomObject]@{
            Folder = $Folder
            TotalFiles = $AllFiles.Count
            MarkdownFiles = $MarkdownFiles.Count
            OtherFiles = $OtherFiles.Count
            Subdirectories = $Subdirs.Count
            TotalSizeMB = [math]::Round($TotalSize / 1MB, 2)
            AvgSizeKB = $AvgSize
        }
        $TotalResults += $FolderResult
    } else {
        Write-Host "❌ Folder not found: $Folder" -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host "📈 SUMMARY ANALYSIS" -ForegroundColor Magenta
Write-Host "===================" -ForegroundColor Magenta
$GrandTotal = ($TotalResults | Measure-Object TotalFiles -Sum).Sum
$GrandMD = ($TotalResults | Measure-Object MarkdownFiles -Sum).Sum
$GrandSize = ($TotalResults | Measure-Object TotalSizeMB -Sum).Sum

Write-Host "🎯 VERIFICATION SCOPE:" -ForegroundColor Green
Write-Host "   • Total Files to Review: $GrandTotal" -ForegroundColor Green
Write-Host "   • Markdown Files (Primary): $GrandMD" -ForegroundColor Green
Write-Host "   • Total Content Size: $GrandSize MB" -ForegroundColor Green
Write-Host ""

Write-Host "🔍 NEXT PHASE: Content Rules Compliance Check" -ForegroundColor Cyan
Write-Host "   Phase 2 will analyze STSA copilot instructions compliance..." -ForegroundColor Gray