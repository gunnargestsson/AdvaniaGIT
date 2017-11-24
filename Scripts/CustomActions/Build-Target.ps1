# Start the script
$SaveSourceFileName = Join-Path $SetupParameters.Repository 'Source\Source.txt'
Build-NAVObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings -TargetFileName Target.txt -IncludeCustomization $true -SaveSourceFileName $SaveSourceFileName
