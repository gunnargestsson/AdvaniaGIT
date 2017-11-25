New-Item -Path $SetupParameters.buildSourcePath -ItemType Directory -ErrorAction SilentlyContinue
$SaveSourceFileName = Join-Path $SetupParameters.buildSourcePath 'Source.txt'
Build-NAVObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings -TargetFileName Target.txt -IncludeCustomization $true -SaveSourceFileName $SaveSourceFileName
