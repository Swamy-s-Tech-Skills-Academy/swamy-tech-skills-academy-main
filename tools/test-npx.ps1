# Test script matching docs-lint.ps1
param(
    [switch]$Fix
)

$fixArg = if ($Fix) { '--fix' } else { '' }

Write-Host "Testing npx command..." -ForegroundColor Yellow
Write-Host "fixArg: '$fixArg'" -ForegroundColor Yellow
& npx --yes markdownlint-cli2 --no-globs --config .markdownlint-cli2.yaml $fixArg