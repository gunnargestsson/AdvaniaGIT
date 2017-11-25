New-Item -Path $SetupParameters.buildSource -ItemType Directory -ErrorAction SilentlyContinue
$SaveSourceFileName = Join-Path $SetupParameters.buildSource 'Source.txt'
Build-NAVObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings -TargetFileName Target.txt -IncludeCustomization $true -SaveSourceFileName $SaveSourceFileName
