param(
    [switch]$Fix
)

# Run markdownlint-cli2 across repo docs. Use --fix if -Fix is supplied.
# Note: Patterns are now handled by .markdownlint-cli2.yaml config file
# This script no longer passes patterns to avoid overriding config

$fixArg = if ($Fix) { '--fix' } else { '' }

Write-Host 'Running markdownlint-cli2...' -ForegroundColor Cyan

# Change to repository root directory (parent of tools folder)
Push-Location (Split-Path $PSScriptRoot -Parent)
Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
Write-Host "Config file exists: $(Test-Path .markdownlint-cli2.yaml)" -ForegroundColor Yellow

try {
    Write-Host "Running command: npx --yes markdownlint-cli2 --no-globs --config .markdownlint-cli2.yaml $fixArg" -ForegroundColor Yellow
    npx --yes markdownlint-cli2 --no-globs --config .markdownlint-cli2.yaml $fixArg
}
finally {
    Pop-Location
}
