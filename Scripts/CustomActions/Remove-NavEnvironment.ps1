if ($BranchSettings.instanceName -ne "") {
    Write-Host "Requesting removal of NAV Environment for branch" $Setupparameters.Branchname
    if ($BranchSettings.dockerContainerId -eq "") {
        Load-InstanceAdminTools -SetupParameters $Setupparameters
        Remove-NAVEnvironment -BranchSettings $BranchSettings
        UnLoad-InstanceAdminTools
    } else {
        docker.exe kill $($BranchSettings.dockerContainerName)
        $BranchSettings = Clear-BranchSettings -BranchId $BranchSettings.branchId 
    }
}

