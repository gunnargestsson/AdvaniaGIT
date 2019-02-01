if ($SetupParameters.BuildMode) {  
    if ([Bool](Get-Module NAVContainerHelper)) {
        $Apps = Get-ChildItem -Path (Join-Path $SetupParameters.repository "Dependencies") -Filter "*.app"
        foreach ($app in $Apps) {
            Publish-NavContainerApp -containerName $BranchSettings.dockerContainerName -appFile $app.FullName -skipVerification -sync -install 
        }
    } else {
        $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId    
        Install-NAVAppInDocker -Session $Session -SetupParameters $SetupParameters -AppFolderPath (Join-Path $SetupParameters.repository "Dependencies")    
    }
}    
