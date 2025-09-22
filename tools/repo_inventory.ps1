<#
.SYNOPSIS
  Produce a high-level inventory of the repository (read-only).
#>

Write-Host "Repository root: $(Get-Location)" -ForegroundColor Cyan
Write-Host 'Top-level files:' -ForegroundColor Cyan
Get-ChildItem -File | Select-Object Name,Length | Format-Table -AutoSize

Write-Host ''; Write-Host 'Top-level directories and file counts (recursively):' -ForegroundColor Cyan
Get-ChildItem -Directory | ForEach-Object { $count=(Get-ChildItem -Path $_.FullName -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object).Count; Write-Host ($_.Name + ': ' + $count + ' files') }

Write-Host ''; Write-Host 'Top README snippets:' -ForegroundColor Cyan
if (Test-Path 'README.md') { Write-Host '---- root/README.md ----'; Get-Content README.md -TotalCount 5 }
if (Test-Path '01_ReferenceLibrary/README.md') { Write-Host '---- 01_ReferenceLibrary/README.md ----'; Get-Content '01_ReferenceLibrary/README.md' -TotalCount 5 }
