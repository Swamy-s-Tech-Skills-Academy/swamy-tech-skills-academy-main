param(
    [switch]$Fix
)

$fixArg = $Fix ? "--fix" : ""

Write-Host "PowerShell version: $($PSVersionTable.PSVersion)"
Write-Host "Script root: $(Split-Path -Parent $MyInvocation.MyCommand.Path)"
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Write-Host "Calculated repo root: $repoRoot"

Push-Location $repoRoot
Write-Host "Current directory after Push-Location: $(Get-Location)"

$configPath = Join-Path $repoRoot ".markdownlint-cli2.yaml"
Write-Host "Config file path: $configPath"
Write-Host "Config file exists: $(Test-Path $configPath)"

$command = "& npx --yes markdownlint-cli2 --no-globs --config `"$configPath`" $fixArg"
Write-Host "Command being executed: $command"

try {
    Invoke-Expression $command
}
finally {
    Pop-Location
    Write-Host "Current directory after Pop-Location: $(Get-Location)"
}