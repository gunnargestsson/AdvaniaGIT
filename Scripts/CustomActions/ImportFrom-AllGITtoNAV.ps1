Remove-NAVLastCommitId -BranchSettings $BranchSettings 
& (Join-Path $PSScriptRoot 'ImportFrom-GITtoNAV.ps1')
