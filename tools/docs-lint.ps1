param(
    [switch]$Fix
)

# Run markdownlint-cli2 across repo docs. Use --fix if -Fix is supplied.
$patterns = @(
    'README.md',
    '01_ReferenceLibrary/**/*.md',
    '02_Planning-and-Development/**/*.md',
    '05_Todos/**/*.md',
    '07_LearningGround/**/*.md',
    'Daily-Migration-Tracker.md',
    'Migration-Plan-Todos-LearningGround.md',
    '.github/**/*.md',
    # Exclude image files
    '!01_ReferenceLibrary/**/*.png',
    '!01_ReferenceLibrary/**/*.jpg',
    '!01_ReferenceLibrary/**/*.jpeg',
    '!01_ReferenceLibrary/**/*.gif',
    '!01_ReferenceLibrary/**/*.svg',
    '!01_ReferenceLibrary/**/*.bmp',
    '!01_ReferenceLibrary/**/*.ico',
    '!02_Planning-and-Development/**/*.png',
    '!02_Planning-and-Development/**/*.jpg',
    '!02_Planning-and-Development/**/*.jpeg',
    '!02_Planning-and-Development/**/*.gif',
    '!02_Planning-and-Development/**/*.svg',
    '!02_Planning-and-Development/**/*.bmp',
    '!02_Planning-and-Development/**/*.ico'
)

# Remove the filtering since we're using negated patterns
$filteredPatterns = $patterns

$fixArg = if ($Fix) { '--fix' } else { '' }

Write-Host 'Running markdownlint-cli2...' -ForegroundColor Cyan
npx --yes markdownlint-cli2 $fixArg @filteredPatterns
