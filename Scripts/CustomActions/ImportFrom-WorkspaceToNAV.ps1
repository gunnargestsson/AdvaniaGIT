if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

$ObjectsPath = (Join-Path $SetupParameters.workFolder 'Objects')
if (Get-ChildItem -Path $ObjectsPath) {
    $lastNAVCommitId = Get-NAVLastCommitId -BranchSettings $BranchSettings
    if ($lastNAVCommitId -gt '') {
        Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $ObjectsPath -SkipDeleteCheck
    } elseif ($SetupParameters.objectProperties -eq "false") {
        Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path (Join-Path $ObjectsPath "*.txt") -ImportAction Overwrite -SynchronizeSchemaChanges Force 
    } else {
        Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $ObjectsPath -MarkToDelete
    }    

    $lastCommitIDd = Get-GitLastCommitId
    if ($lastCommitIDd -gt '') {
        Set-NAVLastCommitId -BranchSettings $BranchSettings -LastCommitID (Get-GitLastCommitId)
    }
}