Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
& (Join-Path $PSScriptRoot 'ImportFrom-StandardTestObjectsToNAV.ps1')
& (Join-Path $PSScriptRoot 'ImportFrom-GITTestObjectsToNAV.ps1')