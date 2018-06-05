if ($BranchSettings.instanceName -ne "") {
    Write-Host "Requesting removal of NAV Environment for branch" $Setupparameters.Branchname
    if ($BranchSettings.dockerContainerId -eq "") {
        Load-InstanceAdminTools -SetupParameters $Setupparameters
        Remove-NAVEnvironment -BranchSettings $BranchSettings
        UnLoad-InstanceAdminTools
    } else {
        if ([Bool](Get-Module NAVContainerHelper)) {
            Remove-NavContainer -containerName $BranchSettings.dockerContainerName
        } else {
            $dockerContainer = Get-DockerContainers | Where-Object -Property Names -ieq $BranchSettings.dockerContainerName
            if ($dockerContainer) {
                Write-Host "Killing and removing Docker Container $($BranchSettings.dockerContainerName)..."
                $dockerContainerName = docker.exe kill $($BranchSettings.dockerContainerName)
                $dockerContainerName = docker.exe rm $($BranchSettings.dockerContainerName)
            }
        }
        Edit-DockerHostRegiststration -RemoveHostName $BranchSettings.dockerContainerName 
        $BranchSettings = Clear-BranchSettings -BranchId $BranchSettings.branchId
        
    }
}

