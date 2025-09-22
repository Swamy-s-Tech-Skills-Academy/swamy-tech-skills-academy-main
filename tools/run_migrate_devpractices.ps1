param(
    [switch]$Preview,
    [switch]$Commit
)

$script = Join-Path (Split-Path $MyInvocation.MyCommand.Path) 'migrate_devpractices.ps1'
if (-not (Test-Path $script)) { Write-Host "Migration script not found: $script" -ForegroundColor Red; exit 1 }

if ($Preview) {
    Write-Host 'Running preview (WhatIfMode)...' -ForegroundColor Cyan
    & $script -WhatIfMode
}
else {
    if ($Commit) { Write-Host 'Running migration script (will commit changes)...' -ForegroundColor Cyan; & $script -Commit }
    else { Write-Host 'Running migration script (no commit)...' -ForegroundColor Cyan; & $script }
}
