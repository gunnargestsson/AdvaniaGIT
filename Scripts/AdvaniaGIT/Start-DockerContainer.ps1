function Start-DockerContainer
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [String]$AdminPassword
    )
    
    $DockerSettings = Get-DockerSettings 
    Write-Host "Connecting to repository $($DockerSettings.RepositoryPath)..."
    if ($DockerSettings.RepositoryPassword -gt "") {
        docker.exe login $($DockerSettings.RepositoryPath) -u $($DockerSettings.RepositoryUserName) -p $($DockerSettings.RepositoryPassword)
    }
    Write-Host "Preparing Docker Container for Dynamics NAV..."
    $adminUsername = $env:USERNAME
    if ($AdminPassword -eq $null -or $AdminPassword -eq "") {
        $AdminPassword = Get-NAVPassword -Message "Enter password for user $adminUsername on the Docker Image" 
    }
    $volume = "$($SetupParameters.Repository):C:\GIT"
    $rootPath = "$($SetupParameters.rootPath):C:\Host"
    $image = $SetupParameters.dockerImage
    docker.exe pull $image
    $DockerContainerId = docker.exe run -m 5G -v "$volume" -v "$rootPath" -e ACCEPT_EULA=Y -e username="$adminUsername" -e password="$AdminPassword" -e auth=Windows --detach $image
    Write-Host "Docker Container $DockerContainerId starting..."
    $Session = New-DockerSession -DockerContainerId $DockerContainerId
    $DockerContainerName = Get-DockerContainerName -Session $Session

    $WaitForHealty = $true
    $LoopNo = 1
    while ($WaitForHealty -and $LoopNo -lt 20) {        
        $dockerContainer = Get-DockerContainers | Where-Object -Property Id -ieq $DockerContainerName
        Write-Host "Container status: $($dockerContainer.Status)..."
        $WaitForHealty = $dockerContainer.Status -match "(health: starting)" -or $dockerContainer.Status -match "(unhealthy)"
        if ($WaitForHealty) { Start-Sleep -Seconds 10 }
        $LoopNo ++
    }
    if (!($dockerContainer.Status -match "(healthy)")) {
        Write-Error "Container $DockerContainerName unable to start !" -ErrorAction Stop
    }


    $DockerSettings = Install-DockerAdvaniaGIT -Session $Session -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
    Edit-DockerHostRegiststration -AddHostName $DockerContainerName -AddIpAddress (Get-DockerIPAddress -Session $Session)

    $BranchSettings.databaseServer = $DockerContainerName
    $BranchSettings.dockerContainerName = $DockerContainerName
    $BranchSettings.dockerContainerId = $DockerContainerId
    $BranchSettings.clientServicesPort = $DockerSettings.BranchSettings.clientServicesPort
    $BranchSettings.managementServicesPort = $DockerSettings.BranchSettings.managementServicesPort
    $BranchSettings.developerServicesPort = $DockerSettings.BranchSettings.developerServicesPort
    $BranchSettings.databaseInstance = $DockerSettings.BranchSettings.databaseInstance
    $BranchSettings.databaseName = $DockerSettings.BranchSettings.databaseName
    $BranchSettings.instanceName = $DockerSettings.BranchSettings.instanceName

    Update-BranchSettings -BranchSettings $BranchSettings
    Remove-PSSession -Session $Session 
}
