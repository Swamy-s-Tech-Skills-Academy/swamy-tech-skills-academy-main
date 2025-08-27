param(
    [switch]$Fix
)

# Run markdownlint-cli2 across repo docs. Use --fix if -Fix is supplied.
$patterns = @(
    'README.md',
    '01_LeadArchitectKnowledgeBase/**/*.md',
    '02_LearningJourney/**/*.md',
    '03_ReferenceLibrary/**/*.md',
    '04_LegacyContent/**/*.md',
    '05_Todos/**/*.md',
    '.github/**/*.md'
)

$fixArg = if ($Fix) { '--fix' } else { '' }

Write-Host 'Running markdownlint-cli2...' -ForegroundColor Cyan
npx --yes markdownlint-cli2 $fixArg @patterns
