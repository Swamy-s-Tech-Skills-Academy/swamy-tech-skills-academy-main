param(
    [switch]$Fix
)

# Run markdownlint-cli2 across repo docs. Use --fix if -Fix is supplied.
# Note: Patterns are now handled by .markdownlint-cli2.yaml config file
# This script no longer passes patterns to avoid overriding config

$fixArg = if ($Fix) { '--fix' } else { '' }

Write-Host 'Running markdownlint-cli2...' -ForegroundColor Cyan

# Change to repository root directory (parent of tools folder)
$repoRoot = Split-Path $PSScriptRoot -Parent
Write-Host "Script root: $PSScriptRoot" -ForegroundColor Yellow
Write-Host "Calculated repo root: $repoRoot" -ForegroundColor Yellow
Push-Location $repoRoot
Write-Host "Current directory after Push-Location: $(Get-Location)" -ForegroundColor Yellow
$configPath = Join-Path $repoRoot '.markdownlint-cli2.yaml'
Write-Host "Config file path: $configPath" -ForegroundColor Yellow
Write-Host "Config file exists: $(Test-Path $configPath)" -ForegroundColor Yellow

Write-Host "PowerShell version: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
Write-Host "Current directory right before npx: $(Get-Location)" -ForegroundColor Yellow
Write-Host "Running command: npx --yes markdownlint-cli2 --no-globs --config `"$configPath`" $fixArg" -ForegroundColor Yellow

# Use Invoke-Expression instead of & call operator for better command line handling
$command = "npx --yes markdownlint-cli2 --no-globs --config `"$configPath`" $fixArg"
Invoke-Expression $command

Pop-Location
Write-Host "Current directory after Pop-Location: $(Get-Location)" -ForegroundColor Yellow
