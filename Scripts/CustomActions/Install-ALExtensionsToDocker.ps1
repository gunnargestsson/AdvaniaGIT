if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
    if ([Bool](Get-Module NAVContainerHelper)) {
        $Apps = Get-ChildItem -Path (Join-Path $BranchWorkFolder "out") -Filter "*.app"
        foreach ($app in $Apps) {
            Publish-NavContainerApp -containerName $BranchSettings.dockerContainerName -appFile $app.FullName -skipVerification -sync -install 
        }
    } else {        
        $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId        
        Install-NAVAppInDocker -Session $Session -SetupParameters $SetupParameters -AppFolderPath (Join-Path $BranchWorkFolder "out") 
    }
}    
