<#
.SYNOPSIS
    Migrate the entire 97_Legacy-Migration-Archive into canonical `01_ReferenceLibrary` folders.

.DESCRIPTION
    - Runs in preview mode by default when `-WhatIfMode` is specified.
    - Safely computes repo-relative paths and will map
      `01_ReferenceLibrary/97_Legacy-Migration-Archive/<section>/...` ->
      `01_ReferenceLibrary/<section>/...` preserving subpaths.
    - Uses `git mv` for tracked files and `Move-Item` + `git add` for untracked files.
    - Provides a dry-run preview that prints exact operations it would run.

.PARAMETER Root
    Legacy archive root (relative to repo root). Default: '01_ReferenceLibrary/97_Legacy-Migration-Archive'

.PARAMETER WhatIfMode
    Preview only. No filesystem or git changes.

.PARAMETER Commit
    When specified, will run `git commit` after staging changes.

.EXAMPLE
    .\migrate_legacy_archive.ps1 -WhatIfMode

#>

param(
    [string]$Root = '01_ReferenceLibrary/97_Legacy-Migration-Archive',
    [switch]$WhatIfMode,
    [switch]$Commit
)

function Info($m) { Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn($m) { Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m) { Write-Host "[ERROR] $m" -ForegroundColor Red }

Info "Repo root: $(Get-Location)"
Info "Legacy root: $Root"
if ($WhatIfMode) { Info 'Preview mode: No changes will be made.' }

if (-not (Test-Path -LiteralPath $Root)) { Warn "Legacy root not found: $Root"; exit 0 }

# Build mapping: all files under Root -> target under 01_ReferenceLibrary
$files = Get-ChildItem -LiteralPath $Root -Recurse -File -Force | Sort-Object FullName
if (-not $files) { Info 'No files found under legacy root.'; exit 0 }

$plan = @()
foreach ($f in $files) {
    $full = $f.FullName
    # compute repo-relative path (use forward slashes)
    $repoRoot = (Get-Location).Path.TrimEnd('\') + '\\'
    $rel = $full.Substring($repoRoot.Length) -replace '\\', '/'
    $target = $rel -replace '^01_ReferenceLibrary/97_Legacy-Migration-Archive', '01_ReferenceLibrary'
    $plan += [PSCustomObject]@{ Source = $rel; Target = $target; Size = $f.Length }
}

# Summarize counts by top-level section under legacy
$summary = $plan | Group-Object { ($_.'Source' -split '/')[2] } | Sort-Object Name
Info "Found $($plan.Count) files in legacy archive. Sections: $($summary.Count)"
foreach ($s in $summary) { Info "Section: $($s.Name)  Count: $($s.Count)" }

# Detect collisions: multiple sources mapping to same target
$collisions = $plan | Group-Object -Property Target | Where-Object { $_.Count -gt 1 }
if ($collisions) {
    Warn "Detected $($collisions.Count) target collisions (multiple sources mapping to same target)."
}

# Print sample mapping and write full mapping to tools/legacy-mapping.csv
$mapPath = 'tools/legacy-mapping.csv'
New-Item -Path (Split-Path $mapPath) -ItemType Directory -Force | Out-Null
$plan | ForEach-Object { "$($_.Source),$($_.Target),$($_.Size)" } | Out-File -FilePath $mapPath -Encoding UTF8
Info "Wrote full mapping to $mapPath"

Info 'Sample mapping (first 200 entries):'
$plan | Select-Object -First 200 | ForEach-Object { Write-Host "$($_.Source) -> $($_.Target) ($($_.Size) bytes)" }

if ($collisions) {
    Info 'List of collisions (targets with multiple source files):'
    $collisions | ForEach-Object { Write-Host "Target: $($_.Name)"; $_.Group | ForEach-Object { Write-Host "  - $($_.Source)" } }
}

# Build preview operations list
$ops = @()
foreach ($p in $plan) {
    $src = $p.Source
    $tgt = $p.Target
    # check if source is tracked by git (git ls-files returns path relative to repo)
    $isTracked = $false
    try {
        $res = git ls-files -- "$src" 2>$null
        if ($res -and $res.Trim() -ne '') { $isTracked = $true }
    }
    catch { }
    if ($isTracked) {
        $ops += [PSCustomObject]@{ Op = 'git mv'; Source = $src; Target = $tgt }
    }
    else {
        $ops += [PSCustomObject]@{ Op = 'move'; Source = $src; Target = $tgt }
    }
}

Info "Planned operations: $($ops.Count)"
Info 'Sample operations (first 200):'
$ops | Select-Object -First 200 | ForEach-Object { Write-Host "$($_.Op): $($_.Source) -> $($_.Target)" }

# Save operations preview
$opsPath = 'tools/legacy-ops-preview.csv'
$ops | ForEach-Object { "$($_.Op),$($_.Source),$($_.Target)" } | Out-File -FilePath $opsPath -Encoding UTF8
Info "Wrote ops preview to $opsPath"

if ($WhatIfMode) { Info 'Preview complete. No changes made.'; exit 0 }

# If not WhatIfMode, execute operations carefully
Info 'Executing migration operations...'
foreach ($o in $ops) {
    $src = $o.Source
    $tgt = $o.Target
    $dstDir = Split-Path $tgt -Parent
    if (-not (Test-Path -LiteralPath $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
    if ($o.Op -eq 'git mv') {
        Info "git mv: $src -> $tgt"
        git mv -- "$src" "$tgt"
    }
    else {
        Info "Move: $src -> $tgt"
        Move-Item -LiteralPath $src -Destination $tgt -Force
        try { git add -- "$tgt" } catch { }
    }
}

# Remove empty directories under Root
Info 'Removing empty directories under legacy root (if any)...'
$dirs = Get-ChildItem -LiteralPath $Root -Recurse -Directory -Force | Sort-Object FullName -Descending
foreach ($d in $dirs) {
    $children = Get-ChildItem -LiteralPath $d.FullName -Force -ErrorAction SilentlyContinue
    if (-not $children) { Remove-Item -LiteralPath $d.FullName -Force -Recurse; Info "Removed dir: $($d.FullName)" }
}

# Optionally remove root if empty
$rootChildren = Get-ChildItem -LiteralPath $Root -Force -ErrorAction SilentlyContinue
if (-not $rootChildren) { Remove-Item -LiteralPath $Root -Force -Recurse; Info "Removed source root: $Root" } else { Info "Source root not empty, left in place: $Root" }

# Stage and optionally commit
Info 'Staging all changes (git add -A)'
git add -A
if ($Commit) {
    $msg = 'chore(migration): move legacy archive content into ReferenceLibrary canonical folders'
    try { git commit -m "$msg"; Info 'Commit created.' } catch { Warn 'git commit failed or there were no changes to commit.' }
}

Info 'Migration script finished.'
