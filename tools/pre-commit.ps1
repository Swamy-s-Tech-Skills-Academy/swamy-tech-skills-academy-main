param()
$ErrorActionPreference = 'Stop'

# Get staged file list (Added, Copied, Renamed, Modified)
$files = git diff --cached --name-only --diff-filter=ARCM | Out-String
$files = $files -split "`r?`n" | Where-Object { $_ -ne '' }

if (-not $files) { exit 0 }

# Find paths that contain a segment starting with 00_
$offenders = @()
foreach ($f in $files) {
    if ($f -match '(^|/|\\)00_[^/\\]+') { $offenders += $f }
}

if ($offenders.Count -gt 0) {
    Write-Error "pre-commit: Files or folders starting with 00_ are not allowed. Use 01_ or later."
    Write-Host "Offending paths:" -ForegroundColor Yellow
    $offenders | ForEach-Object { Write-Host " - $_" }
    Write-Host "Guidance:"
    Write-Host " - Number from 01_. Use 00_ only as a short-lived deprecation stub."
    Write-Host " - See 01_ReferenceLibrary/02_ORGANIZATION_GUIDE.md → Numbering Rules."
    exit 1
}

exit 0
