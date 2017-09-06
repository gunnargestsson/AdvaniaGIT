if ($BranchSettings.instanceName -ne "") {
    Write-Host "Requesting removal of NAV Environment for branch" $Setupparameters.Branchname
    if ($BranchSettings.dockerContainerId -eq "") {
        Load-InstanceAdminTools -SetupParameters $Setupparameters
        Remove-NAVEnvironment -BranchSettings $BranchSettings
        UnLoad-InstanceAdminTools
    } else {
        $ClickOnceUrl = "http://$($BranchSettings.dockerContainerName):8080/NAV/Win/Deployment/Microsoft.Dynamics.Nav.Client.application"
        $InstalledApplicationNotMSI = Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall | foreach-object {Get-ItemProperty $_.PsPath}
        $UninstallString = $InstalledApplicationNotMSI | Where-Object -Property UrlUpdateInfo -EQ $ClickOnceUrl | Select uninstallstring
        if ($UninstallString) {
            cmd /c $UninstallString.UninstallString
        }

        $dockerContainer = Get-DockerContainers | Where-Object -Property Id -ieq $BranchSettings.dockerContainerName
        if ($dockerContainer) {
            Write-Host "Killing and removing Docker Container $($BranchSettings.dockerContainerName)..."
            $dockerContainerName = docker.exe kill $($BranchSettings.dockerContainerName)
            $dockerContainerName = docker.exe rm $($BranchSettings.dockerContainerName)

        }
        Edit-DockerHostRegiststration -RemoveHostName $BranchSettings.dockerContainerName 
        $BranchSettings = Clear-BranchSettings -BranchId $BranchSettings.branchId
        
    }
}

