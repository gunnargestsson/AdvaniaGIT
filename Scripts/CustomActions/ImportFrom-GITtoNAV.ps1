Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}
Load-ModelTools -SetupParameters $SetupParameters
$ObjectsPath = Build-Solution -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $SetupParameters.ObjectsPath
$lastNAVCommitId = Get-NAVLastCommitId -BranchSettings $BranchSettings
if ($lastNAVCommitId -gt '') {
    $ObjectList = Get-GitModifiedFiles -GitCommitId $lastNAVCommitId
    if ($ObjectList -ne $null) {
        Copy-NAVObjectsToWorkspace -SetupParameters $SetupParameters -ObjectList $ObjectList
        $fileList = Get-ChildItem -Path (Join-Path $SetupParameters.workFolder 'Objects')
        if ($fileList) {
            Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath (Join-Path $SetupParameters.workFolder 'Objects') -SkipDeleteCheck
        } else {
            Write-Host -ForegroundColor Red "Nothing to import..."
        }
    }
} elseif ($SetupParameters.objectProperties -eq "false") {
    & (Join-Path $PSScriptRoot 'Export-GITtoSource.ps1')
    Write-Host "Importing All objects..."
    if ($SetupParameters.skipDeleteCheck -eq "false") {
        Write-Host "Marking all object as deleted..."
        $command = "UPDATE [dbo].[Object] SET [Version List] = '#DELETED' WHERE [ID] < 2000000004"
        Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword | Out-Null
    }
    Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path (Join-Path $SetupParameters.WorkFolder "Source.txt") -ImportAction Overwrite -SynchronizeSchemaChanges Force 
} else {
    if ($SetupParameters.skipDeleteCheck -eq "true") {
        Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $ObjectsPath -SkipDeleteCheck
    } else {
        Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $ObjectsPath -MarkToDelete
    }
}    
Compile-UncompiledObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings
& (Join-Path $PSScriptRoot 'Start-ForceSync.ps1')
Import-PermissionSets -SetupParameters $SetupParameters -BranchSettings $BranchSettings
$lastCommitIDd = Get-GitLastCommitId
if ($lastCommitIDd -gt '') {
    Set-NAVLastCommitId -BranchSettings $BranchSettings -LastCommitID (Get-GitLastCommitId)
}
UnLoad-ModelTools