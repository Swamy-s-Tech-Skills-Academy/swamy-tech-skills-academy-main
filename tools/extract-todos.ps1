<#
.SYNOPSIS
Extract TODO/FIXME markers from repository files and produce a CSV report.

.DESCRIPTION
Scans the workspace for common TODO patterns and writes a CSV to `tools/todo-report.csv` with columns: Path, Line, Marker, Text

.NOTES
Run from repository root (PowerShell):
    ./tools/extract-todos.ps1
#>

Param(
    [string]$Root = ".",
    [string]$OutCsv = "tools/todo-report.csv"
)

$patterns = @("TODO", "FIXME", "# TODO", "// TODO", "Migration TODO", "MIGRATION TODO")

Write-Host "Scanning repository for TODO markers..." -ForegroundColor Cyan

$results = @()

Get-ChildItem -Path $Root -Recurse -Include *.md, *.ps1, *.py, *.cs, *.js, *.ts, *.java -File -ErrorAction SilentlyContinue | ForEach-Object {
    $path = $_.FullName
    $lines = Get-Content -LiteralPath $path -ErrorAction SilentlyContinue
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $ln = $lines[$i]
        foreach ($p in $patterns) {
            if ($ln -match [regex]::Escape($p)) {
                $results += [PSCustomObject]@{
                    Path   = $path
                    Line   = $i + 1
                    Marker = $p
                    Text   = $ln.Trim()
                }
                break
            }
        }
    }
}

if ($results.Count -eq 0) {
    Write-Host "No TODO markers found." -ForegroundColor Green
}
else {
    $results | Sort-Object Path, Line | Export-Csv -Path $OutCsv -NoTypeInformation -Encoding UTF8
    Write-Host "Wrote $($results.Count) TODO entries to $OutCsv" -ForegroundColor Green
}
