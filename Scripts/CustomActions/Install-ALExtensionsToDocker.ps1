if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
        
    if (Test-Path (Join-Path $SetupParameters.repository "Dependencies\*.app")) {
        Install-NAVAppInDocker -Session $Session -SetupParameters $SetupParameters -AppFolderPath (Join-Path $SetupParameters.repository "Dependencies")
    }
    Install-NAVAppInDocker -Session $Session -SetupParameters $SetupParameters -AppFolderPath (Join-Path $BranchWorkFolder "out")    
}    
