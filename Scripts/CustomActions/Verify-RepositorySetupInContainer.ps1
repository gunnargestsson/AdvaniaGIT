if ([Bool](Get-Module $SetupParameters.containerHelperModuleName)) {
    if ((Get-NavContainerSharedFolders -containerName $BranchSettings.dockerContainerName).Keys -notcontains $SetupParameters.Repository) {
        Copy-FileToNavContainer -containerName $BranchSettings.dockerContainerName -localPath $SetupParameters.setupPath -containerPath "C:\GIT" 
    }
}