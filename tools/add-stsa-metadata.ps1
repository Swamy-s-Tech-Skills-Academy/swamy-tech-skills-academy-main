# Add STSA Metadata to Deep-Dive Files
# Adds Learning Level, Prerequisites, Estimated Time, and Learning Objectives

param(
    [Parameter(Mandatory=$false)]
    [string]$FolderPath = "01_ReferenceLibrary\01_Development\01_software-design-principles\02_SOLID-Principles"
)

$ErrorActionPreference = "Stop"

Write-Host "🎯 Adding STSA Metadata to Deep-Dive files" -ForegroundColor Yellow

# Define the files that need metadata
$filesToUpdate = @(
    "04_SOLID-Principles-Deep-Dive-PartA.md",
    "04_SOLID-Principles-Deep-Dive-PartB.md",
    "04_SOLID-Principles-Deep-Dive-PartC.md",
    "04_SOLID-Principles-Deep-Dive-PartD.md",
    "04_SOLID-Principles-Deep-Dive-PartE.md",
    "04_SOLID-Principles-Deep-Dive-PartF.md"
)

# Define metadata for each file
$metadataMap = @{
    "04_SOLID-Principles-Deep-Dive-PartA.md" = @{
        Level = "Advanced"
        Prerequisites = "SOLID Parts 1-5, OOP fundamentals, C# basics"
        Time = "27 minutes"
        Objectives = @(
            "Master advanced SOLID principle applications in enterprise scenarios",
            "Understand architectural trade-offs and design decisions",
            "Apply SOLID principles to complex, real-world C# codebases",
            "Evaluate and refactor existing code using SOLID principles"
        )
    }
    "04_SOLID-Principles-Deep-Dive-PartB.md" = @{
        Level = "Advanced"
        Prerequisites = "Deep-Dive Part A, Strategy Pattern knowledge"
        Time = "27 minutes"
        Objectives = @(
            "Implement advanced Open/Closed Principle patterns",
            "Design extensible architectures using strategy and factory patterns",
            "Handle complex extension scenarios without modifying existing code",
            "Apply OCP in microservices and plugin architectures"
        )
    }
    "04_SOLID-Principles-Deep-Dive-PartC.md" = @{
        Level = "Advanced"  
        Prerequisites = "Deep-Dive Parts A-B, inheritance concepts"
        Time = "27 minutes"
        Objectives = @(
            "Master Liskov Substitution Principle in complex inheritance hierarchies",
            "Design robust behavioral contracts and invariants",
            "Identify and resolve subtle LSP violations",
            "Apply LSP in generic programming and interface design"
        )
    }
    "04_SOLID-Principles-Deep-Dive-PartD.md" = @{
        Level = "Advanced"
        Prerequisites = "Deep-Dive Parts A-C, interface design experience"
        Time = "27 minutes"
        Objectives = @(
            "Implement sophisticated Interface Segregation strategies",
            "Design cohesive, focused interfaces for complex systems",
            "Apply ISP in API design and microservices communication",
            "Balance interface granularity with practical maintainability"
        )
    }
    "04_SOLID-Principles-Deep-Dive-PartE.md" = @{
        Level = "Advanced"
        Prerequisites = "Deep-Dive Parts A-D, dependency injection knowledge"
        Time = "27 minutes"
        Objectives = @(
            "Master advanced Dependency Inversion and IoC patterns",
            "Design flexible, testable architectures with proper abstractions",
            "Implement sophisticated dependency injection scenarios",
            "Apply DIP in enterprise and distributed system architectures"
        )
    }
    "04_SOLID-Principles-Deep-Dive-PartF.md" = @{
        Level = "Advanced"
        Prerequisites = "Complete Deep-Dive series (Parts A-E)"
        Time = "27 minutes"
        Objectives = @(
            "Synthesize all SOLID principles in comprehensive system design",
            "Apply SOLID principles to legacy code modernization",
            "Balance competing principles and make architectural trade-offs",
            "Lead SOLID-based code reviews and team mentoring"
        )
    }
}

$totalUpdated = 0

foreach ($fileName in $filesToUpdate) {
    $filePath = Join-Path $FolderPath $fileName
    
    if (Test-Path $filePath) {
        Write-Host "🔧 Processing: $fileName" -ForegroundColor Cyan
        
        $content = Get-Content $filePath -Raw
        $metadata = $metadataMap[$fileName]
        
        # Find the first heading line
        $lines = $content -split "`r?`n"
        $firstHeadingIndex = -1
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "^#\s+") {
                $firstHeadingIndex = $i
                break
            }
        }
        
        if ($firstHeadingIndex -eq -1) {
            Write-Host "  ⚠️ Could not find heading in $fileName" -ForegroundColor Yellow
            continue
        }
        
        # Build the metadata block
        $metadataBlock = @()
        $metadataBlock += ""
        $metadataBlock += "**Learning Level**: $($metadata.Level)"
        $metadataBlock += "**Prerequisites**: $($metadata.Prerequisites)"
        $metadataBlock += "**Estimated Time**: $($metadata.Time)"
        $metadataBlock += ""
        $metadataBlock += "## 🎯 Learning Objectives"
        $metadataBlock += ""
        $metadataBlock += "By the end of this 27-minute session, you will:"
        $metadataBlock += ""
        
        # Add objectives as bullet points
        foreach ($objective in $metadata.Objectives) {
            $metadataBlock += "- $objective"
        }
        $metadataBlock += ""
        
        # Insert metadata after the first heading
        $newLines = @()
        $newLines += $lines[0..$firstHeadingIndex]
        $newLines += $metadataBlock
        $newLines += $lines[($firstHeadingIndex + 1)..($lines.Count - 1)]
        
        # Write back to file
        $newContent = $newLines -join "`n"
        $newContent | Set-Content $filePath -NoNewline
        
        Write-Host "  ✅ Added STSA metadata to $fileName" -ForegroundColor Green
        $totalUpdated++
    } else {
        Write-Host "  ❌ File not found: $fileName" -ForegroundColor Red
    }
}

Write-Host "`n🎉 METADATA UPDATE SUMMARY:" -ForegroundColor Yellow
Write-Host "📁 Files updated: $totalUpdated of $($filesToUpdate.Count)" -ForegroundColor Green
Write-Host "🎯 All Deep-Dive files now have comprehensive STSA metadata!" -ForegroundColor Green

# Verification
Write-Host "`n🔍 Verification..." -ForegroundColor Cyan
$allFilesHaveMetadata = $true

foreach ($fileName in $filesToUpdate) {
    $filePath = Join-Path $FolderPath $fileName
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        if ($content -match "\*\*Learning Level\*\*" -and $content -match "Learning Objectives") {
            Write-Host "  ✅ $fileName - Metadata confirmed" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $fileName - Metadata missing" -ForegroundColor Red
            $allFilesHaveMetadata = $false
        }
    }
}

if ($allFilesHaveMetadata) {
    Write-Host "`n🏆 ALL FILES NOW HAVE COMPLETE STSA METADATA!" -ForegroundColor Green
} else {
    Write-Host "`n⚠️ Some files still missing metadata" -ForegroundColor Yellow
}