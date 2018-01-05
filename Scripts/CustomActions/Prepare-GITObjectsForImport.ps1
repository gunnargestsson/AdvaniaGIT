if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-ModelTools -SetupParameters $SetupParameters
    $lastNAVCommitId = Get-NAVLastCommitId -BranchSettings $BranchSettings
    $ObjectsPath = Build-Solution -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $SetupParameters.ObjectsPath       

    if ($ObjectsPath -eq $SetupParameters.ObjectsPath) {
        if ($lastNAVCommitId -gt '' ) {
            $ObjectList = Get-GitModifiedFiles -GitCommitId $lastNAVCommitId
            Copy-NAVObjectsToWorkspace -SetupParameters $SetupParameters -ObjectList $ObjectList
        } else {
            Copy-NAVObjectsToWorkspace -SetupParameters $SetupParameters -AllObjects
        }
    }

    if ($SetupParameters.objectProperties -eq "false") {
        $command = "UPDATE [dbo].[Object] SET [Version List] = '#DELETED' WHERE [ID] < 2000000004"
        Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command | Out-Null        
    }    

}