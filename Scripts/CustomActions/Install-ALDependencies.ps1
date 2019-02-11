if ($SetupParameters.BuildMode) {  
    if ([Bool](Get-Module NAVContainerHelper)) {
        $Apps = Get-ChildItem -Path (Join-Path $SetupParameters.repository "Dependencies") -Filter "*.app"
        foreach ($app in $Apps | Sort-Object -Property LastWriteTime) {
            Publish-NavContainerApp -containerName $BranchSettings.dockerContainerName -appFile $app.FullName -skipVerification -sync -install 
        }
    } else {
        $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId    
        Install-NAVAppInDocker -Session $Session -SetupParameters $SetupParameters -AppFolderPath (Join-Path $SetupParameters.repository "Dependencies")    
    }
    Remove-Item -Path (Join-Path $SetupParameters.repository "Dependencies\*.*") -Recurse -ErrorAction SilentlyContinue
}    
