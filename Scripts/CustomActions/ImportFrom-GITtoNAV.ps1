Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 

& (Join-Path $PSScriptRoot 'Prepare-GITObjectsForImport.ps1')
& (Join-Path $PSScriptRoot 'ImportFrom-WorkspaceToNAV.ps1')
& (Join-Path $PSScriptRoot 'Compile-ImportedNAVObjects.ps1')

