# Design Patterns Broken Links Fix Script
# This script identifies and fixes broken links in the Design Patterns folder

param(
    [string]$FolderPath = "01_ReferenceLibrary/01_Development/01_software-design-principles/03_Design-Patterns",
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

Write-Host "🔧 Design Patterns Broken Links Fix" -ForegroundColor Cyan

# Define link mapping: broken link -> replacement
$linkMappings = @{
    # Pattern folder references -> existing main pattern files
    "../behavioral-patterns/mediator" = "#"
    "../behavioral-patterns/chain-of-responsibility" = "#"
    "../behavioral-patterns/state" = "#"
    "../behavioral-patterns/observer" = "09A_Design-Patterns-Part4A-Observer-Pattern-Fundamentals.md"
    "../behavioral-patterns/template-method" = "13A_Design-Patterns-Part8A-Template-Method-Fundamentals.md"
    "../behavioral-patterns/chain" = "#"
    "../behavioral-patterns/visitor" = "#"
    "../behavioral-patterns" = "#"
    
    # Structural pattern references -> existing files or placeholders
    "../../structural-patterns/adapter" = "#"
    "../../structural-patterns/decorator" = "11A_Design-Patterns-Part6A-Decorator-Pattern-Fundamentals.md"
    "../../structural-patterns/facade" = "#"
    "../../structural-patterns/composite" = "#"
    "../../structural-patterns/proxy" = "#"
    "../structural-patterns" = "#"
    
    # Creational pattern references -> existing files
    "../../creational-patterns/prototype" = "#"
    "../../creational-patterns/builder" = "07A_Design-Patterns-Part2A-Builder-Pattern-Fundamentals.md"
    "../../creational-patterns/factory-method" = "06A_Design-Patterns-Part1A-Factory-Pattern-Fundamentals.md"
    "../../creational-patterns/factory" = "06A_Design-Patterns-Part1A-Factory-Pattern-Fundamentals.md"
    "../creational-patterns/builder" = "07A_Design-Patterns-Part2A-Builder-Pattern-Fundamentals.md"
    "../creational-patterns/factory-method" = "06A_Design-Patterns-Part1A-Factory-Pattern-Fundamentals.md"
    
    # Missing pattern files -> existing files
    "06B_Design-Patterns-Part1B-Factory-Method-Pattern.md" = "06A_Design-Patterns-Part1A-Factory-Pattern-Fundamentals.md"
    "06C_Design-Patterns-Part1C-Abstract-Factory-Pattern.md" = "06A_Design-Patterns-Part1A-Factory-Pattern-Fundamentals.md"
    "11B_Design-Patterns-Part6B-Decorator-Pattern-HTTP-Pipeline.md" = "11A_Design-Patterns-Part6A-Decorator-Pattern-Fundamentals.md"
    
    # External folder references -> placeholders or existing content
    "../../patterns/dependency-injection" = "#"
    "../../patterns/fluent-api" = "#"
    "../../patterns/configuration" = "#"
    "../../patterns/service-registry" = "#"
    "../../patterns/configuration-management" = "#"
    "../../patterns/dsl" = "#"
    
    # Architecture references -> placeholders
    "../../architecture/microservices-config" = "#"
    "../../architecture/microservice-patterns" = "#"
    "../../architecture/service-architecture" = "#"
    "../../devops/deployment-environments" = "#"
    
    # Other missing references -> placeholders
    "../../testing/test-data-builders" = "#"
    "../../testing/test-data-management" = "#"
    "../../testing/advanced-patterns" = "#"
    "../../testing/automation" = "#"
    "../../business-patterns" = "#"
    "../../business-patterns/rule-engines" = "#"
    "../../algorithm-patterns" = "#"
    "../../algorithms" = "#"
    "../../performance-patterns" = "#"
    "../../dependency-patterns" = "#"
    "../../integration-patterns" = "#"
    "../../integration-patterns/saga" = "#"
    "../../integration-patterns/message-bus" = "#"
    "../../distributed-patterns" = "#"
    "../../networking-patterns" = "#"
    "../../io-patterns" = "#"
    "../../web-patterns" = "#"
    "../../database-patterns" = "#"
    "../../advanced-patterns" = "#"
    "../../advanced-patterns/cqrs" = "#"
    "../../advanced-patterns/event-sourcing" = "#"
    "../../architectural-patterns/event-sourcing" = "#"
    "../../architectural-patterns/mvc" = "#"
    "../../architectural-patterns/mvvm" = "#"
    "../../architectural-patterns/cqrs" = "#"
    "../../libraries/reactive-extensions" = "#"
    "../../../applications/text-editors" = "#"
    "../../../applications/version-control" = "#"
    "../../../../testing/automation" = "#"
}

$filesFixed = 0
$linksFixed = 0

# Get all markdown files in the Design Patterns folder
$mdFiles = Get-ChildItem -Path $FolderPath -Filter "*.md" -Recurse

Write-Host "📁 Found $($mdFiles.Count) markdown files to check" -ForegroundColor Yellow

foreach ($file in $mdFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $originalContent = $content
    $fileLinksFixed = 0
    
    # Apply each mapping
    foreach ($brokenLink in $linkMappings.Keys) {
        $replacement = $linkMappings[$brokenLink]
        
        # Look for markdown links containing the broken link
        $pattern = "\[([^\]]+)\]\($([^)]*$brokenLink[^)]*)\)"
        
        if ($content -match $pattern) {
            Write-Host "  🔗 Found broken link in $($file.Name): $brokenLink" -ForegroundColor Red
            
            # Replace with new link
            if ($replacement -eq "#") {
                # Replace with placeholder - keep text but remove link
                $content = $content -replace "\[([^\]]+)\]\([^)]*$([^)]*$brokenLink[^)]*)\)", '**$1** (Pattern not yet available)'
            } else {
                # Replace with working link
                $content = $content -replace "\[([^\]]+)\]\([^)]*$([^)]*$brokenLink[^)]*)\)", "[$1]($replacement)"
            }
            
            $fileLinksFixed++
            $linksFixed++
        }
    }
    
    # If file was modified, write it back
    if ($content -ne $originalContent) {
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            Write-Host "  ✅ Fixed $fileLinksFixed links in $($file.Name)" -ForegroundColor Green
        } else {
            Write-Host "  🔄 Would fix $fileLinksFixed links in $($file.Name)" -ForegroundColor Yellow
        }
        $filesFixed++
    }
}

Write-Host "`n📊 Summary:" -ForegroundColor Cyan
Write-Host "  Files processed: $($mdFiles.Count)" -ForegroundColor White
Write-Host "  Files with fixes: $filesFixed" -ForegroundColor White  
Write-Host "  Total links fixed: $linksFixed" -ForegroundColor White

if ($DryRun) {
    Write-Host "`n⚠️  This was a dry run. Use -DryRun:`$false to apply changes." -ForegroundColor Yellow
} else {
    Write-Host "`n✅ Link fixes applied successfully!" -ForegroundColor Green
}