param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

$ErrorActionPreference = "Stop"

Write-Host "🎯 Creating comprehensive SOLID-Principles markdown compliance fix..." -ForegroundColor Green

# Get all markdown files in the folder
$files = Get-ChildItem -Path $FolderPath -Filter "*.md" -File

foreach ($file in $files) {
    Write-Host "`n📝 Processing: $($file.Name)" -ForegroundColor Yellow
    
    $content = Get-Content $file.FullName -Raw
    if (-not $content) {
        Write-Host "  ⚠️ Empty file, skipping..." -ForegroundColor Yellow
        continue
    }
    
    $originalContent = $content
    $fixesApplied = 0
    
    # 1. Fix MD046 - Convert fenced code blocks to indented
    $fencedPattern = '(?m)^(\s*)```([a-zA-Z]*)\s*$\n((?:(?!^(\s*)```\s*$).*\n?)*?)^(\s*)```\s*$'
    $content = $content -replace $fencedPattern, {
        param($match)
        $indent = $match.Groups[1].Value
        $codeContent = $match.Groups[3].Value
        
        # Convert each line to 4-space indented
        $lines = $codeContent -split "`n"
        $indentedLines = $lines | ForEach-Object { 
            if ($_.Trim() -eq "") { "" } else { "    $_" }
        }
        return $indentedLines -join "`n"
    }
    if ($content -ne $originalContent) { $fixesApplied++; Write-Host "  ✅ Fixed MD046 violations" -ForegroundColor Green }
    
    # 2. Fix MD012 - Remove multiple consecutive blank lines
    $originalContent = $content
    $content = $content -replace '(?m)^\s*$\n(?:\s*$\n)+', "`n`n"
    if ($content -ne $originalContent) { $fixesApplied++; Write-Host "  ✅ Fixed MD012 violations" -ForegroundColor Green }
    
    # 3. Fix MD009 - Remove trailing spaces (except intentional line breaks)
    $originalContent = $content
    $content = $content -replace '(?m)[ \t]+$', ''
    if ($content -ne $originalContent) { $fixesApplied++; Write-Host "  ✅ Fixed MD009 violations" -ForegroundColor Green }
    
    # 4. Fix MD037 - Remove spaces inside emphasis markers  
    $originalContent = $content
    $content = $content -replace '\*\s+([^*]+?)\s+\*', '*$1*'
    $content = $content -replace '_\s+([^_]+?)\s+_', '_$1_'
    if ($content -ne $originalContent) { $fixesApplied++; Write-Host "  ✅ Fixed MD037 violations" -ForegroundColor Green }
    
    # 5. Fix MD038 - Remove spaces inside code spans
    $originalContent = $content
    $content = $content -replace '`\s+([^`]+?)\s+`', '`$1`'
    if ($content -ne $originalContent) { $fixesApplied++; Write-Host "  ✅ Fixed MD038 violations" -ForegroundColor Green }
    
    # 6. Fix MD031 - Ensure blank lines around fenced code blocks (if any remain)
    $originalContent = $content
    $content = $content -replace '(?m)^([^\n]*[^\s\n])\n(```)', '$1`n`n$2'
    $content = $content -replace '(?m)(```[^\n]*)\n([^\s\n])', '$1`n`n$2'
    if ($content -ne $originalContent) { $fixesApplied++; Write-Host "  ✅ Fixed MD031 violations" -ForegroundColor Green }
    
    # Write back to file if changes were made
    if ($fixesApplied -gt 0) {
        Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
        Write-Host "  ✨ Applied $fixesApplied fix(es) to $($file.Name)" -ForegroundColor Cyan
    } else {
        Write-Host "  ℹ️ No violations found in $($file.Name)" -ForegroundColor Gray
    }
}

Write-Host "`n🎉 Markdown compliance fix completed!" -ForegroundColor Green
Write-Host "Run markdownlint to verify all violations are resolved..." -ForegroundColor Cyan