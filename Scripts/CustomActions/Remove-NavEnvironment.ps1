if ($BranchSettings.instanceName -ne "") {
    Write-Host "Requesting removal of NAV Environment for branch" $Setupparameters.Branchname
    if ($BranchSettings.dockerContainerName -eq "") {
        Load-InstanceAdminTools -SetupParameters $Setupparameters
        Remove-NAVEnvironment -BranchSettings $BranchSettings
        UnLoad-InstanceAdminTools
    } else {
        Remove-NavContainer -containerName $BranchSettings.dockerContainerName
        
        $DockerSettings = Get-DockerSettings 
        $DockerSettings.ClientFolders = $DockerSettings.ClientFolders | Where-Object -Property dockerContainerName -NE $BranchSettings.dockerContainerName 
        Update-DockerSettings -DockerSettings $DockerSettings 
        $BranchSettings = Clear-BranchSettings -BranchId $BranchSettings.branchId
    }
}

