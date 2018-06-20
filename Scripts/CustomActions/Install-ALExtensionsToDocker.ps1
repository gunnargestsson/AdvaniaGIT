if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.WorkFolder $SetupParameters.branchId
    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
    Install-NAVAppInDocker -Session $Session -SetupParameters $SetupParameters -AppFolderPath (Join-Path $BranchWorkFolder "out")    
}    
