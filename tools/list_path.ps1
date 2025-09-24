<#
.SYNOPSIS
  List files and directories under a path (read-only).

.PARAMETER Path
  Path to list (relative to repo root). Default: the legacy DevelopmentPractices path.

EXAMPLE
  .\tools\list_path.ps1 -Path '01_ReferenceLibrary/97_Legacy-Migration-Archive/03_Development/DevelopmentPractices'
#>
param(
    [string]$Path = '01_ReferenceLibrary/97_Legacy-Migration-Archive/03_Development/DevelopmentPractices'
)

Write-Host "Listing: $Path" -ForegroundColor Cyan
if (-not (Test-Path -LiteralPath $Path)) { Write-Host 'Path does not exist.' -ForegroundColor Yellow; exit 0 }
Get-ChildItem -LiteralPath $Path -Recurse -Force | Select-Object @{Name='Type';Expression={if ($_.PSIsContainer) {'Dir'} else {'File'}}},FullName,Length | Format-Table -AutoSize
