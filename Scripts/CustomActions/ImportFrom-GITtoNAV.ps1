Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name
} else {    
    Load-ModelTools -SetupParameters $SetupParameters
    $ObjectsPath = Build-Solution -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $SetupParameters.ObjectsPath
    if ($SetupParameters.objectProperties -eq "false") {
        & (Join-Path $PSScriptRoot 'Export-GITtoSource.ps1')
        Write-Host "Importing All objects..."
        $command = "UPDATE [dbo].[Object] SET [Version List] = '#DELETED' WHERE [ID] < 2000000004"
        Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command | Out-Null
        Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path (Join-Path $SetupParameters.WorkFolder "Source.txt") -ImportAction Overwrite -SynchronizeSchemaChanges Force 
    } else {
        $lastNAVCommitId = Get-NAVLastCommitId -BranchSettings $BranchSettings
        if ($lastNAVCommitId -gt '') {
           $ObjectList = Get-GitModifiedFiles -GitCommitId $lastNAVCommitId
           if ($ObjectList -ne $null) {
               Copy-NAVObjectsToWorkspace -SetupParameters $SetupParameters -ObjectList $ObjectList
               Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath (Join-Path $SetupParameters.workFolder 'Objects')
            }
        } else {
           Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $ObjectsPath -MarkToDelete
        }
    }
    Compile-UncompiledObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Wait
    Import-PermissionSets -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    $lastCommitIDd = Get-GitLastCommitId
    if ($lastCommitIDd -gt '') {
        Set-NAVLastCommitId -BranchSettings $BranchSettings -LastCommitID (Get-GitLastCommitId)
    }
}