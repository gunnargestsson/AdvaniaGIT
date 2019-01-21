if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
        
    Install-NAVAppInDocker -Session $Session -SetupParameters $SetupParameters -AppFolderPath (Join-Path $BranchWorkFolder "out")    
}    
