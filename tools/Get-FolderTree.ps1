param (
    [string]$Path = ".",
    [string[]]$ExcludePatterns = @(".git", ".bin", ".obj", ".vs", ".venv", "node_modules", "__pycache__"),
    [string]$OutputFile = "repo-structure.txt"
)

function Show-Tree {
    param (
        [string]$Path,
        [string]$Indent = "",
        [ref]$Result
    )

    $items = Get-ChildItem -LiteralPath $Path -Force | Sort-Object Name
    foreach ($item in $items) {
        # Skip excluded folders/files
        $skip = $false
        foreach ($pattern in $ExcludePatterns) {
            if ($item.Name -like $pattern) {
                $skip = $true
                break
            }
        }
        if ($skip) { continue }

        if ($item.PSIsContainer) {
            $line = "$Indent├── $($item.Name)"
            $Result.Value += $line
            Show-Tree -Path $item.FullName -Indent ("$Indent│   ") -Result $Result
        }
        else {
            $line = "$Indent├── $($item.Name)"
            $Result.Value += $line
        }
    }
}

# Collect results
$Result = @()
$Result += "$Path"

Show-Tree -Path $Path -Result ([ref]$Result)

# Write to console
$Result | ForEach-Object { Write-Output $_ }

# Save to file
$Result | Set-Content -Path $OutputFile -Encoding UTF8

Write-Host "✅ Folder structure saved to $OutputFile"
