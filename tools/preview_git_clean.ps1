<#
.SYNOPSIS
  Preview which untracked files/git-clean candidates would be removed under a path.

.PARAMETER Path
  Path to preview (relative to repo root). Default: the legacy DevelopmentPractices path.

EXAMPLE
  .\tools\preview_git_clean.ps1 -Path '01_ReferenceLibrary/97_Legacy-Migration-Archive/03_Development/DevelopmentPractices'
#>
param(
    [string]$Path = '01_ReferenceLibrary/97_Legacy-Migration-Archive/03_Development/DevelopmentPractices'
)

Write-Host "Previewing git clean for path: $Path" -ForegroundColor Cyan
Write-Host 'Running: git clean -nd -- "' + $Path + '"' -ForegroundColor DarkCyan
try {
    git clean -nd -- "$Path"
}
catch {
    Write-Host 'git clean preview failed. Ensure this is a git repo and git is on PATH.' -ForegroundColor Yellow
}
