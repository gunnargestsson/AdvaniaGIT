$objectList = Get-GitModifiedFiles -GitCommitId (Get-GitLastCommitId)
if ($objectList -ne $null) {
    Remove-NAVObjectsProperties -SetupParameters $SetupParameters -ObjectList $objectList 
}