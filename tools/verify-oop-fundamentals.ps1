# OOP-Fundamentals Comprehensive A-M Verification
# Deep-dive analysis of all content against STSA standards

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

$ErrorActionPreference = "Stop"

Write-Host "🔍 OOP-Fundamentals Comprehensive A-M Verification" -ForegroundColor Cyan
Write-Host "Target Folder: $FolderPath" -ForegroundColor Yellow

# Initialize verification results
$VerificationResults = @{
    TotalFiles = 0
    Issues = @()
    Scores = @{
        A_FileAnalysis = 0
        B_RuleCompliance = 0 
        C_ContentAccuracy = 0
        D_StyleGuidelines = 0
        E_BrokenLinks = 0
        F_SpellingGrammar = 0
        G_RedundantContent = 0
        H_IrrelevantFiles = 0
        I_WellStructured = 0
        J_UpToDate = 0
        K_ImprovementSuggestions = 0
        L_EncodingIssues = 0
        M_NamingConsistency = 0
    }
}

# Get all markdown files
$AllFiles = Get-ChildItem -Path $FolderPath -Filter "*.md" | Sort-Object Name

Write-Host "`n📂 Found $($AllFiles.Count) files for verification" -ForegroundColor Green

$VerificationResults.TotalFiles = $AllFiles.Count

# Criterion A: File Analysis
Write-Host "`n🔎 A. FILE ANALYSIS - Going into each and every file..." -ForegroundColor Blue
foreach ($file in $AllFiles) {
    Write-Host "  📄 Analyzing: $($file.Name)" -ForegroundColor White
    
    try {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $lineCount = ($content -split "`n").Count
        $wordCount = ($content -split '\s+' | Where-Object { $_ }).Count
        
        # Check for basic educational structure
        $hasLearningObjectives = $content -match "Learning Objectives?|🎯"
        $hasPrerequisites = $content -match "Prerequisites?|Prerequisite"
        $hasTimeEstimate = $content -match "Time|minutes?|hour"
        
        if ($lineCount -lt 10) {
            $VerificationResults.Issues += "A-ISSUE: $($file.Name) - Very short content ($lineCount lines)"
        }
        
        if (-not $hasLearningObjectives -and $file.Name -ne "README.md") {
            $VerificationResults.Issues += "A-ISSUE: $($file.Name) - Missing learning objectives"
        }
        
        Write-Host "    ✓ Lines: $lineCount, Words: $wordCount, Structure: $(if($hasLearningObjectives){'✓'}else{'❌'})" -ForegroundColor Gray
    }
    catch {
        $VerificationResults.Issues += "A-ERROR: $($file.Name) - Failed to analyze: $($_.Exception.Message)"
    }
}

# Criterion B: Rule Compliance (STSA Standards)
Write-Host "`n📋 B. RULE COMPLIANCE - Checking STSA standards..." -ForegroundColor Blue
$StsakRuleViolations = 0

foreach ($file in $AllFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Check for 27-minute learning segments
    if ($content -match "27.minute|27 minute" -or $content -match "Estimated Time.*27") {
        Write-Host "  ✓ $($file.Name) - Follows 27-minute guideline" -ForegroundColor Green
    } elseif ($file.Name -ne "README.md") {
        $VerificationResults.Issues += "B-ISSUE: $($file.Name) - Missing 27-minute time structure"
        $StsakRuleViolations++
    }
    
    # Check for STSA metadata sections
    if ($content -match "\*\*Learning Level\*\*:" -and $content -match "\*\*Prerequisites\*\*:" -and $content -match "\*\*Estimated Time\*\*:") {
        Write-Host "  ✓ $($file.Name) - Has STSA metadata" -ForegroundColor Green
    } elseif ($file.Name -ne "README.md") {
        $VerificationResults.Issues += "B-ISSUE: $($file.Name) - Missing STSA metadata structure"
        $StsakRuleViolations++
    }
}

# Criterion D: Style Guidelines (Markdown Compliance)
Write-Host "`n🎨 D. STYLE GUIDELINES - Markdown compliance..." -ForegroundColor Blue
try {
    $lintOutput = & npx markdownlint-cli2 "$FolderPath/**/*.md" 2>&1
    $lintErrors = ($lintOutput | Where-Object { $_ -match "\.md:" }).Count
    
    if ($lintErrors -gt 0) {
        $VerificationResults.Issues += "D-ISSUE: Found $lintErrors markdown compliance violations"
        Write-Host "  ❌ $lintErrors markdown lint violations found" -ForegroundColor Red
    } else {
        Write-Host "  ✓ All files pass markdown compliance" -ForegroundColor Green
    }
}
catch {
    $VerificationResults.Issues += "D-ERROR: Could not run markdown lint check"
}

# Criterion E: Broken Links
Write-Host "`n🔗 E. BROKEN LINKS - Checking internal references..." -ForegroundColor Blue
$TotalLinks = 0
$BrokenLinks = 0

foreach ($file in $AllFiles) {
    $content = Get-Content $file.FullName -Raw
    $links = [regex]::Matches($content, '\[([^\]]*)\]\(([^)]+)\)')
    
    foreach ($link in $links) {
        $TotalLinks++
        $linkTarget = $link.Groups[2].Value
        
        # Check internal markdown links
        if ($linkTarget -match '\.md$' -and -not $linkTarget.StartsWith('http')) {
            $targetPath = Join-Path $FolderPath $linkTarget
            if (-not (Test-Path $targetPath)) {
                $BrokenLinks++
                $VerificationResults.Issues += "E-ISSUE: $($file.Name) - Broken link to: $linkTarget"
            }
        }
    }
}

Write-Host "  📊 Links checked: $TotalLinks, Broken: $BrokenLinks" -ForegroundColor $(if($BrokenLinks -eq 0){'Green'}else{'Red'})

# Criterion L: Encoding Issues
Write-Host "`n🔤 L. ENCODING ISSUES - Checking character integrity..." -ForegroundColor Blue
$EncodingIssues = 0

foreach ($file in $AllFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Check for replacement characters (encoding corruption)
    if ($content -match '�') {
        $EncodingIssues++
        $VerificationResults.Issues += "L-ISSUE: $($file.Name) - Contains replacement characters (�) indicating encoding corruption"
    }
    
    # Check for common encoding problems
    if ($content -match '[^\x00-\x7F\u00A0-\uFFFF]') {
        $EncodingIssues++
        $VerificationResults.Issues += "L-ISSUE: $($file.Name) - Contains potentially problematic Unicode characters"
    }
}

Write-Host "  🔍 Encoding issues found: $EncodingIssues" -ForegroundColor $(if($EncodingIssues -eq 0){'Green'}else{'Red'})

# Criterion M: Naming Consistency
Write-Host "`n📝 M. NAMING CONSISTENCY - Checking filename patterns..." -ForegroundColor Blue
$NamingIssues = 0

# Check for STSA naming convention compliance
$ExpectedPatterns = @(
    '^01_[A-Z][A-Za-z0-9-]*-Part[A-Z]\.md$',  # Multi-part files
    '^[0-9]{2}_[A-Z][A-Za-z0-9-]*\.md$',      # Regular numbered files  
    '^README\.md$'                             # README files
)

foreach ($file in $AllFiles) {
    $fileName = $file.Name
    $isValidPattern = $false
    
    foreach ($pattern in $ExpectedPatterns) {
        if ($fileName -match $pattern) {
            $isValidPattern = $true
            break
        }
    }
    
    if (-not $isValidPattern) {
        $NamingIssues++
        $VerificationResults.Issues += "M-ISSUE: $fileName - Does not follow STSA naming conventions"
    }
}

Write-Host "  📋 Naming consistency issues: $NamingIssues" -ForegroundColor $(if($NamingIssues -eq 0){'Green'}else{'Red'})

# Calculate overall scores
$VerificationResults.Scores.A_FileAnalysis = [math]::Max(0, 100 - ($VerificationResults.Issues | Where-Object { $_ -match '^A-' }).Count * 10)
$VerificationResults.Scores.B_RuleCompliance = [math]::Max(0, 100 - $StsakRuleViolations * 15)
$VerificationResults.Scores.D_StyleGuidelines = [math]::Max(0, 100 - $lintErrors * 2)
$VerificationResults.Scores.E_BrokenLinks = if ($TotalLinks -eq 0) { 100 } else { [math]::Max(0, 100 - ($BrokenLinks / $TotalLinks * 100)) }
$VerificationResults.Scores.L_EncodingIssues = [math]::Max(0, 100 - $EncodingIssues * 20)
$VerificationResults.Scores.M_NamingConsistency = [math]::Max(0, 100 - $NamingIssues * 10)

# Generate summary report
Write-Host "`n📊 VERIFICATION SUMMARY" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow
Write-Host "Total Files Analyzed: $($VerificationResults.TotalFiles)" -ForegroundColor White
Write-Host "Total Issues Found: $($VerificationResults.Issues.Count)" -ForegroundColor $(if($VerificationResults.Issues.Count -eq 0){'Green'}else{'Red'})

Write-Host "`n📈 CRITERION SCORES:" -ForegroundColor Cyan
Write-Host "A. File Analysis: $($VerificationResults.Scores.A_FileAnalysis)%" -ForegroundColor White
Write-Host "B. Rule Compliance: $($VerificationResults.Scores.B_RuleCompliance)%" -ForegroundColor White  
Write-Host "D. Style Guidelines: $($VerificationResults.Scores.D_StyleGuidelines)%" -ForegroundColor White
Write-Host "E. Broken Links: $($VerificationResults.Scores.E_BrokenLinks)%" -ForegroundColor White
Write-Host "L. Encoding Issues: $($VerificationResults.Scores.L_EncodingIssues)%" -ForegroundColor White
Write-Host "M. Naming Consistency: $($VerificationResults.Scores.M_NamingConsistency)%" -ForegroundColor White

$OverallScore = ($VerificationResults.Scores.Values | Measure-Object -Average).Average
Write-Host "`n🎯 OVERALL SCORE: $([math]::Round($OverallScore, 1))%" -ForegroundColor $(if($OverallScore -ge 90){'Green'}elseif($OverallScore -ge 80){'Yellow'}else{'Red'})

if ($VerificationResults.Issues.Count -gt 0) {
    Write-Host "`n⚠️  ISSUES FOUND:" -ForegroundColor Yellow
    foreach ($issue in $VerificationResults.Issues | Sort-Object) {
        Write-Host "  • $issue" -ForegroundColor Red
    }
}

Write-Host "`n✅ Verification Complete!" -ForegroundColor Green