<#
.SYNOPSIS
  Run `git clean -fd` for a specified path with an optional force flag.

.PARAMETER Path
  Path to clean (relative to repo root). Default: the legacy DevelopmentPractices path.

.PARAMETER Force
  If set, no interactive confirmation is requested.

EXAMPLE
  .\tools\perform_git_clean.ps1 -Path '...' -Force
#>
param(
    [string]$Path = '01_ReferenceLibrary/97_Legacy-Migration-Archive/03_Development/DevelopmentPractices',
    [switch]$Force
)

if (-not $Force) {
    $resp = Read-Host "About to run 'git clean -fd -- \"$Path\"'. Type 'yes' to continue"
    if ($resp -ne 'yes') { Write-Host 'Aborting.'; exit 0 }
}

Write-Host "Running: git clean -fd -- \"$Path\"" -ForegroundColor Cyan
try {
    git clean -fd -- "$Path"
}
catch {
    Write-Host 'git clean failed. Check permissions and git availability.' -ForegroundColor Yellow
}
