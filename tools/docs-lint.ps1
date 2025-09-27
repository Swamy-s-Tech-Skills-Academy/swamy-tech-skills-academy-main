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
    '.github/**/*.md'
)

# Filter out image files from the patterns
$filteredPatterns = $patterns | Where-Object { $_ -notmatch '\*\*/\*\.(png|jpg|jpeg|gif|svg|bmp|ico)$' }

$fixArg = if ($Fix) { '--fix' } else { '' }

Write-Host 'Running markdownlint-cli2...' -ForegroundColor Cyan
npx --yes markdownlint-cli2 $fixArg @filteredPatterns
