if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

$objectList = Get-GitModifiedFiles -GitCommitId (Get-GitLastCommitId)
if ($objectList -ne $null) {
    Remove-NAVObjectsProperties -SetupParameters $SetupParameters -ObjectList $objectList 
}