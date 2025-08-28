param(
    [switch]$DumpOnly
)

# Run Lychee link checker in Docker. Uses lychee.toml config.
$patterns = @(
    'README.md',
    '01_LeadArchitectKnowledgeBase/**/*.md',
    '02_LearningJourney/**/*.md',
    '03_ReferenceLibrary/**/*.md',
    '04_LegacyContent/**/*.md',
    '05_Todos/**/*.md',
    '06_AuditFiles/**/*.md',
    '.github/**/*.md'
)

$patternsJoined = $patterns -join ' '

if ($DumpOnly) {
    Write-Host 'Lychee (dump links only)...' -ForegroundColor Cyan
    docker run --rm -w /input -v "${PWD}:/input" lycheeverse/lychee:latest --config lychee.toml --no-progress --dump $patternsJoined
}
else {
    Write-Host 'Lychee (validate links)...' -ForegroundColor Cyan
    docker run --rm -w /input -v "${PWD}:/input" lycheeverse/lychee:latest --config lychee.toml --no-progress $patternsJoined
}
