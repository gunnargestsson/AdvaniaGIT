$SaveSourceFileName = Join-Path $SetupParameters.buildSourcePath 'Source.txt'
Build-NAVObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings -TargetFileName Source.txt -IncludeCustomization $false -SaveSourceFileName $SaveSourceFileName
