if ([Bool](Get-Module NAVContainerHelper)) {
    $DockerRepository = (Get-NavContainerSharedFolders -containerName $BranchSettings.dockerContainerName).Name
    if ([String]::IsNullOrEmpty($DockerRepository)) {
        Copy-FileToNavContainer -containerName $BranchSettings.dockerContainerName -localPath $SetupParameters.setupPath -containerPath "C:\GIT" 
    }
}