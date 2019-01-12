if ($SetupParameters.BuildMode) {
    $SetupParameters.workFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
}

$MergeFolder = (Join-Path $SetupParameters.workFolder 'Merge')
$ConflictFolder = (Join-Path $MergeFolder 'ConflictObjects')

Write-Host "Check for conflicts after merge..."
Write-Host 
$ConflictObjects = Get-ChildItem -Path $ConflictFolder
$ConflictObjects | Format-Table -AutoSize
if ($ConflictObjects) { throw }