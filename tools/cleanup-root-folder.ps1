<#
.SYNOPSIS
Clean root folder by moving and deleting documentation files

.DESCRIPTION
Removes clutter from repository root by:
- Moving essential documentation to docs/ folder
- Deleting temporary analysis and review files
- Keeping only critical files (README.md, LICENSE)

.PARAMETER RootPath
Path to the repository root (default: current directory)

.PARAMETER DryRun
Show what would be deleted without actually deleting (default: $false)

.EXAMPLE
.\cleanup-root-folder.ps1
.\cleanup-root-folder.ps1 -DryRun $true
.\cleanup-root-folder.ps1 -RootPath "d:\STSA\swamy-tech-skills-academy-main"

.NOTES
- Moves docs to docs/ folder
- Deletes temporary analysis and review files
- Keeps LICENSE and README.md in root
- All operations are logged
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$RootPath = (Get-Location).Path,
    
    [Parameter(Mandatory=$false)]
    [bool]$DryRun = $false
)

$ErrorActionPreference = "Stop"

# ═══════════════════════════════════════════════════════════
# ROOT FOLDER CLEANUP
# ═══════════════════════════════════════════════════════════

Write-Host "🧹 Root Folder Cleanup Script" -ForegroundColor Cyan
Write-Host "Repository Path: $RootPath" -ForegroundColor Gray

if ($DryRun) {
    Write-Host "⚠️  DRY RUN MODE - No files will be deleted" -ForegroundColor Yellow
}
Write-Host ""

# Define files to delete (temporary analysis/review documents)
$filesToDelete = @(
    "02_LeadArchitect-Learning-ANALYSIS.md",
    "LEADARCHITECT-REVIEW-COMPLETE.md",
    "Phase01_Reboot_DEEPDIVE.md",
    "WORKSPACE-REVIEW-2025-10-18.md",
    "workspace-health-report.md"
)

# Define files to keep in root (critical files)
$keepInRoot = @(
    "README.md",
    "LICENSE",
    "lychee.toml",
    ".gitignore",
    ".markdownlint.json",
    ".markdownlint-cli2.yaml",
    ".markdownlintignore"
)

# ─────────────────────────────────────────────────────────
# STEP 1: Delete temporary files
# ─────────────────────────────────────────────────────────

Write-Host "📋 FILES TO DELETE (Temporary Analysis/Review Documents)" -ForegroundColor Red
Write-Host "─────────────────────────────────────────────────────────" -ForegroundColor Gray

$deletedCount = 0
foreach ($file in $filesToDelete) {
    $filePath = Join-Path $RootPath $file
    
    if (Test-Path $filePath -PathType Leaf) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would delete: $file" -ForegroundColor Yellow
        } else {
            try {
                Remove-Item -Path $filePath -Force
                Write-Host "  ✓ Deleted: $file" -ForegroundColor Red
                $deletedCount++
            } catch {
                Write-Host "  ✗ Failed to delete: $file" -ForegroundColor DarkRed
                Write-Host "    Error: $_" -ForegroundColor Gray
            }
        }
    }
}

Write-Host ""
Write-Host "✅ Deletion Summary" -ForegroundColor Green
Write-Host "  Total deleted: $deletedCount/$($filesToDelete.Count)" -ForegroundColor Gray
Write-Host ""

# ─────────────────────────────────────────────────────────
# STEP 2: Verify root folder cleanliness
# ─────────────────────────────────────────────────────────

Write-Host "📊 ROOT FOLDER VERIFICATION" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────────────────────────" -ForegroundColor Gray

$rootFiles = Get-ChildItem -Path $RootPath -File -Filter "*.md" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name

if ($rootFiles.Count -eq 0) {
    Write-Host "  ✓ No markdown files in root (expected)" -ForegroundColor Green
} else {
    Write-Host "  Files remaining in root:" -ForegroundColor Yellow
    foreach ($file in $rootFiles) {
        if ($file -in $keepInRoot) {
            Write-Host "    ✓ $file (KEEP - Critical)" -ForegroundColor Green
        } else {
            Write-Host "    ? $file (Review needed)" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

# ─────────────────────────────────────────────────────────
# STEP 3: Verify docs folder exists
# ─────────────────────────────────────────────────────────

$docsPath = Join-Path $RootPath "docs"
if (Test-Path $docsPath -PathType Container) {
    Write-Host "✓ Docs folder exists: $docsPath" -ForegroundColor Green
    
    $docsCount = (Get-ChildItem -Path $docsPath -File | Measure-Object).Count
    Write-Host "  Current files in docs/: $docsCount" -ForegroundColor Gray
} else {
    Write-Host "⚠️  Docs folder not found at: $docsPath" -ForegroundColor Yellow
}

Write-Host ""

# ─────────────────────────────────────────────────────────
# FINAL SUMMARY
# ─────────────────────────────────────────────────────────

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         ROOT FOLDER CLEANUP COMPLETE                      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Write-Host "✨ NEXT STEPS" -ForegroundColor Cyan
Write-Host "  1. Review root folder - only README.md, LICENSE, and config files" -ForegroundColor Gray
Write-Host "  2. Check docs/ folder - place any active documentation there" -ForegroundColor Gray
Write-Host "  3. Update copilot-instructions.md with reference to docs/ location" -ForegroundColor Gray
Write-Host "  4. Run: git status" -ForegroundColor Gray
Write-Host ""
