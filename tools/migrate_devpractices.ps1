<#
.SYNOPSIS
    Move DevelopmentPractices from legacy archive into canonical 01_Development folder.

.DESCRIPTION
    This script moves files found in the legacy path into the canonical location under
    `01_ReferenceLibrary/01_Development/DevelopmentPractices`.

    It will use `git mv` for files already tracked by git and `Move-Item` + `git add`
    for untracked files. The script supports a preview mode (no changes) and an
    optional commit step.

.PARAMETER Source
    Legacy source path (relative to repo root). Default: '01_ReferenceLibrary/97_Legacy-Migration-Archive/03_Development/DevelopmentPractices'

.PARAMETER TargetParent
    Parent folder under which the DevelopmentPractices folder should be created. Default: '01_ReferenceLibrary/01_Development'

.PARAMETER WhatIfMode
    When specified, the script will run in preview mode and print actions that would be taken without performing them.

.PARAMETER Commit
    When specified, the script will run `git commit` after staging changes with a sensible message.

.EXAMPLE
    .\migrate_devpractices.ps1 -WhatIfMode

.EXAMPLE
    .\migrate_devpractices.ps1 -Commit

NOTE: This script performs file-system and git operations when not run in WhatIf mode. Use preview first.
#>

param(
    [string]$Source = '01_ReferenceLibrary/97_Legacy-Migration-Archive/03_Development/DevelopmentPractices',
    [string]$TargetParent = '01_ReferenceLibrary/01_Development',
    [switch]$WhatIfMode,
    [switch]$Commit
)

function Write-Info { param($m) Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Write-Warn { param($m) Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Err { param($m) Write-Host "[ERROR] $m" -ForegroundColor Red }

Write-Info "Repository working dir: $(Get-Location)"
Write-Info "Source: $Source"
Write-Info "Target parent: $TargetParent"
if ($WhatIfMode) { Write-Info 'Preview mode: NO filesystem or git changes will be made.' }

if (-not (Test-Path -LiteralPath $Source)) {
    Write-Warn "Source path not found: $Source. Nothing to do."
    exit 0
}

$target = Join-Path $TargetParent (Split-Path $Source -Leaf)
Write-Info "Computed target: $target"

if (-not $WhatIfMode) {
    New-Item -ItemType Directory -Force -Path $target | Out-Null
}
else {
    Write-Info "(Preview) Would create directory: $target"
}

# Gather tracked files under source
Write-Info 'Querying git for tracked files under source...'
try {
    $trackedRaw = git ls-files -- "$Source/*" 2>$null
    $tracked = if ($trackedRaw) { $trackedRaw -split "\r?\n" | Where-Object { $_ -ne '' } } else { @() }
}
catch {
    Write-Warn "git ls-files failed — git may not be available in PATH or this is not a git repo. Falling back to filesystem-only move."
    $tracked = @()
}

foreach ($t in $tracked) {
    $rel = $t.Substring($Source.Length).TrimStart('/', '\\')
    $dstPath = Join-Path $target $rel
    $dstDir = Split-Path $dstPath -Parent
    if (-not $WhatIfMode -and -not (Test-Path -LiteralPath $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
    if ($WhatIfMode) {
        Write-Info "(Preview) git mv: $t -> $dstPath"
    }
    else {
        Write-Info "git mv: $t -> $dstPath"
        git mv -- "$t" "$dstPath"
    }
}

# Move untracked files
Write-Info 'Enumerating remaining files in source (untracked candidates)...'
$allFiles = Get-ChildItem -LiteralPath $Source -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
$untracked = $allFiles | Where-Object { -not ($tracked -contains $_) }

foreach ($u in $untracked) {
    $rel = $u.Substring($Source.Length).TrimStart('/', '\\')
    $dstPath = Join-Path $target $rel
    $dstDir = Split-Path $dstPath -Parent
    if ($WhatIfMode) {
        Write-Info "(Preview) Move: $u -> $dstPath"
    }
    else {
        if (-not (Test-Path -LiteralPath $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
        Write-Info "Move: $u -> $dstPath"
        Move-Item -LiteralPath $u -Destination $dstPath -Force
        try { git add -- "$dstPath" } catch {}
    }
}

# Remove empty directories under source (descend deepest first)
Write-Info 'Removing empty directories under source (if any)...'
$dirs = Get-ChildItem -LiteralPath $Source -Recurse -Directory -Force | Sort-Object FullName -Descending
foreach ($d in $dirs) {
    $children = Get-ChildItem -LiteralPath $d.FullName -Force -ErrorAction SilentlyContinue
    if (-not $children) {
        if ($WhatIfMode) { Write-Info "(Preview) Remove-Item -Recurse -Force $($d.FullName)" } else { Remove-Item -LiteralPath $d.FullName -Force -Recurse; Write-Info "Removed dir: $($d.FullName)" }
    }
    else {
        Write-Info "Dir not empty, skipping: $($d.FullName)"
    }
}

# Optionally remove root source if empty
try {
    $rootChildren = Get-ChildItem -LiteralPath $Source -Force -ErrorAction SilentlyContinue
    if (-not $rootChildren) {
        if ($WhatIfMode) { Write-Info "(Preview) Remove-Item -Recurse -Force $Source" } else { Remove-Item -LiteralPath $Source -Force -Recurse; Write-Info "Removed source root: $Source" }
    }
    else {
        Write-Info "Source root not empty, left in place: $Source"
    }
}
catch {
    Write-Warn "Could not inspect or remove source root: $_"
}

# Stage and optionally commit
if ($WhatIfMode) {
    Write-Info 'Preview complete. No git staging or commit performed.'
}
else {
    Write-Info 'Staging all changes (git add -A)...'
    git add -A
    if ($Commit) {
        $msg = 'chore(migration): move DevelopmentPractices from legacy archive to 01_Development on current branch'
        try {
            git commit -m "$msg"
            Write-Info 'Commit created.'
        }
        catch {
            Write-Warn 'git commit failed or there were no changes to commit.'
        }
    }
    else {
        Write-Info 'Commit not requested. Changes are staged.'
    }
}

Write-Info 'Script finished.'
