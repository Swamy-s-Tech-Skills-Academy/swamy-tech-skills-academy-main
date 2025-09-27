param(
    [switch]$Fix
)

# Test script that exactly replicates docs-lint.ps1 logic

$fixArg = if ($Fix) { '--fix' } else { '' }

Write-Host 'Running test markdownlint-cli2...' -ForegroundColor Cyan

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
Write-Host "Running command: npx --yes markdownlint-cli2 --no-globs --config $configPath $fixArg" -ForegroundColor Yellow
& npx --yes markdownlint-cli2 --no-globs --config $configPath $fixArg

Pop-Location
Write-Host "Current directory after Pop-Location: $(Get-Location)" -ForegroundColor Yellow