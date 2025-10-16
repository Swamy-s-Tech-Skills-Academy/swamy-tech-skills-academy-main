# Fix Content Compliance Issues for STSA
# Addresses character encoding problems and length violations
# Created: October 16, 2025

param(
    [Parameter(Mandatory=$false)]
    [string]$Path = "01_ReferenceLibrary\01_Development\01_software-design-principles\01_OOP-fundamentals",
    
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

# Configuration
$MaxLineLimit = 175
$BackupSuffix = "_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# Character mapping for common corrupted Unicode
$CharacterMappings = @{
    "ðŸŽ¯" = "🎯"          # Target emoji
    "ðŸ"‹" = "📋"          # Clipboard emoji
    "ðŸ"—" = "🔗"          # Link emoji
    "âœ…" = "✅"          # Checkmark
    "âŒ" = "❌"           # Cross mark
    "ðŸš¨" = "🚨"          # Warning
    "ðŸ'" = "💡"          # Lightbulb
    "ðŸŽ¨" = "🎨"          # Art palette
    "ðŸ"Š" = "📊"          # Chart
    "ðŸ"š" = "📚"          # Books
    "ðŸ"" = "📏"          # Ruler
    "ðŸ›¡ï¸" = "🛡️"         # Shield
    "ðŸ"„" = "🔄"          # Refresh
    "â­" = "⭐"           # Star
    "ðŸš€" = "🚀"          # Rocket
}

# Box drawing character mappings (corrupted Unicode to ASCII)
$BoxCharMappings = @{
    "â"Œ" = "┌"
    "â"€" = "─"
    "â"" = "┐"
    "â"‚" = "│"
    "â"œ" = "├"
    "â"¤" = "┤"
    "â"" = "└"
    "â"˜" = "┘"
    "â"¼" = "┼"
}

function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch($Type) {
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "SUCCESS" { "Green" }
        default { "White" }
    }
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

function Test-FileCompliance {
    param([string]$FilePath)
    
    $issues = @()
    
    if (-not (Test-Path $FilePath)) {
        return @("File does not exist")
    }
    
    # Check line count
    $lineCount = (Get-Content $FilePath | Measure-Object -Line).Lines
    if ($lineCount -gt $MaxLineLimit) {
        $issues += "Exceeds $MaxLineLimit line limit ($lineCount lines)"
    }
    
    # Check for character encoding issues
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    
    if ($content -match "�") {
        $issues += "Contains replacement characters (�)"
    }
    
    foreach ($corrupted in $CharacterMappings.Keys) {
        if ($content -match [regex]::Escape($corrupted)) {
            $issues += "Contains corrupted emoji: $corrupted"
        }
    }
    
    foreach ($corrupted in $BoxCharMappings.Keys) {
        if ($content -match [regex]::Escape($corrupted)) {
            $issues += "Contains corrupted box character: $corrupted"
        }
    }
    
    return $issues
}

function Fix-CharacterEncoding {
    param([string]$FilePath)
    
    Write-Log "Fixing character encoding in $FilePath" "INFO"
    
    if ($WhatIf) {
        Write-Log "WHATIF: Would fix character encoding in $FilePath" "WARNING"
        return
    }
    
    # Create backup
    $backupPath = $FilePath + $BackupSuffix
    Copy-Item $FilePath $backupPath
    Write-Log "Created backup: $backupPath" "INFO"
    
    # Read content
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $originalContent = $content
    
    # Fix corrupted emojis and special characters
    foreach ($mapping in $CharacterMappings.GetEnumerator()) {
        $content = $content -replace [regex]::Escape($mapping.Key), $mapping.Value
    }
    
    # Fix corrupted box drawing characters
    foreach ($mapping in $BoxCharMappings.GetEnumerator()) {
        $content = $content -replace [regex]::Escape($mapping.Key), $mapping.Value
    }
    
    # Fix generic replacement characters with ASCII alternatives
    $content = $content -replace "�", "?"
    
    # Write back to file
    $content | Set-Content $FilePath -Encoding UTF8 -NoNewline
    
    if ($content -ne $originalContent) {
        Write-Log "Fixed character encoding issues in $FilePath" "SUCCESS"
        return $true
    } else {
        Write-Log "No character encoding issues found in $FilePath" "INFO"
        return $false
    }
}

function Split-OversizedFile {
    param([string]$FilePath)
    
    Write-Log "Splitting oversized file: $FilePath" "INFO"
    
    if ($WhatIf) {
        Write-Log "WHATIF: Would split $FilePath into parts" "WARNING"
        return
    }
    
    $lines = Get-Content $FilePath
    $totalLines = $lines.Count
    
    if ($totalLines -le $MaxLineLimit) {
        Write-Log "File $FilePath is within size limits ($totalLines lines)" "INFO"
        return
    }
    
    # Create backup
    $backupPath = $FilePath + $BackupSuffix
    Copy-Item $FilePath $backupPath
    
    # Calculate parts needed
    $partsNeeded = [Math]::Ceiling($totalLines / $MaxLineLimit)
    $baseFileName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $directory = [System.IO.Path]::GetDirectoryName($FilePath)
    
    Write-Log "Splitting into $partsNeeded parts (max $MaxLineLimit lines each)" "INFO"
    
    # Extract metadata from original file
    $metadata = @()
    $contentStart = 0
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^---\s*$" -and $i -gt 5) {
            $contentStart = $i + 1
            break
        }
        $metadata += $lines[$i]
    }
    
    # Split content into parts
    $contentLines = $lines[$contentStart..($lines.Count - 1)]
    $linesPerPart = $MaxLineLimit - $metadata.Count - 10 # Buffer for navigation
    
    for ($part = 0; $part -lt $partsNeeded; $part++) {
        $partLetter = [char](65 + $part) # A, B, C...
        $partFileName = "${baseFileName}-Part${partLetter}.md"
        $partPath = Join-Path $directory $partFileName
        
        $startLine = $part * $linesPerPart
        $endLine = [Math]::Min(($part + 1) * $linesPerPart - 1, $contentLines.Count - 1)
        
        $partContent = @()
        $partContent += $metadata
        $partContent += ""
        $partContent += "**Part ${partLetter} of $partsNeeded**"
        $partContent += ""
        
        # Add navigation
        if ($part -gt 0) {
            $prevLetter = [char](64 + $part) # Previous part
            $partContent += "**Previous**: [Part $prevLetter](${baseFileName}-Part${prevLetter}.md)"
        }
        if ($part -lt $partsNeeded - 1) {
            $nextLetter = [char](66 + $part) # Next part
            $partContent += "**Next**: [Part $nextLetter](${baseFileName}-Part${nextLetter}.md)"
        }
        $partContent += ""
        $partContent += "---"
        $partContent += ""
        
        # Add content for this part
        $partContent += $contentLines[$startLine..$endLine]
        
        $partContent | Out-File $partPath -Encoding UTF8
        Write-Log "Created part: $partPath" "SUCCESS"
    }
    
    # Rename original file
    $originalRenamed = $FilePath -replace "\.md$", "-ORIGINAL.md"
    Rename-Item $FilePath $originalRenamed
    Write-Log "Original file renamed to: $originalRenamed" "INFO"
}

function Test-MarkdownSyntax {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw
    $issues = @()
    
    # Check for proper STSA metadata
    if (-not ($content -match "(?s)\*\*Learning Level\*\*:.*\*\*Prerequisites\*\*:.*\*\*Estimated Time\*\*:")) {
        $issues += "Missing required STSA metadata"
    }
    
    # Check for proper headings structure
    if (-not ($content -match "## 🎯 Learning Objectives")) {
        $issues += "Missing Learning Objectives section"
    }
    
    # Check for Related Topics section
    if (-not ($content -match "## 🔗 Related Topics")) {
        $issues += "Missing Related Topics section"
    }
    
    return $issues
}

# Main execution
function Main {
    Write-Log "Starting STSA Content Compliance Fix" "INFO"
    Write-Log "Target Path: $Path" "INFO"
    Write-Log "Max Line Limit: $MaxLineLimit" "INFO"
    
    if ($WhatIf) {
        Write-Log "WHATIF MODE: No changes will be made" "WARNING"
    }
    
    $files = Get-ChildItem -Path $Path -Filter "*.md" -File
    
    if ($files.Count -eq 0) {
        Write-Log "No markdown files found in $Path" "WARNING"
        return
    }
    
    Write-Log "Found $($files.Count) markdown files" "INFO"
    
    $totalIssues = 0
    $fixedFiles = 0
    
    foreach ($file in $files) {
        Write-Log "`n=== Processing: $($file.Name) ===" "INFO"
        
        $issues = Test-FileCompliance $file.FullName
        
        if ($issues.Count -eq 0) {
            Write-Log "✅ No compliance issues found" "SUCCESS"
            continue
        }
        
        Write-Log "Found $($issues.Count) compliance issues:" "WARNING"
        foreach ($issue in $issues) {
            Write-Log "  - $issue" "WARNING"
        }
        
        $totalIssues += $issues.Count
        
        # Fix character encoding issues
        $encodingFixed = Fix-CharacterEncoding $file.FullName
        
        # Split oversized files
        $lineCount = (Get-Content $file.FullName | Measure-Object -Line).Lines
        if ($lineCount -gt $MaxLineLimit) {
            Split-OversizedFile $file.FullName
        }
        
        # Test markdown syntax
        $syntaxIssues = Test-MarkdownSyntax $file.FullName
        if ($syntaxIssues.Count -gt 0) {
            Write-Log "Markdown syntax issues found:" "WARNING"
            foreach ($issue in $syntaxIssues) {
                Write-Log "  - $issue" "WARNING"
            }
        }
        
        if ($encodingFixed -or $lineCount -gt $MaxLineLimit) {
            $fixedFiles++
        }
    }
    
    Write-Log "`n=== SUMMARY ===" "INFO"
    Write-Log "Files processed: $($files.Count)" "INFO"
    Write-Log "Total issues found: $totalIssues" "INFO"
    Write-Log "Files fixed: $fixedFiles" "SUCCESS"
    
    if (-not $WhatIf -and $fixedFiles -gt 0) {
        Write-Log "`nRecommended next steps:" "INFO"
        Write-Log "1. Review the fixed files for correctness" "INFO"
        Write-Log "2. Run markdown lint: npx markdownlint-cli2 '$Path/**/*.md'" "INFO"
        Write-Log "3. Test markdown preview functionality" "INFO"
        Write-Log "4. Commit changes to git" "INFO"
    }
}

# Execute main function
Main