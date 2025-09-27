param(
    [switch]$Fix
)

# Run markdownlint-cli2 across repo docs. Use --fix if -Fix is supplied.
# Note: Patterns are now handled by .markdownlint-cli2.yaml config file
# This script no longer passes patterns to avoid overriding config

$fixArg = if ($Fix) { '--fix' } else { '' }

Write-Host 'Running markdownlint-cli2...' -ForegroundColor Cyan
npx --yes markdownlint-cli2 --no-globs $fixArg
