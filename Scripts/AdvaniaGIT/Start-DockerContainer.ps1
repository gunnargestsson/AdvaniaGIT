function Start-DockerContainer
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings
    )
    
    $DockerSettings = Get-DockerSettings 
    Write-Host "Connecting to repository $($DockerSettings.RepositoryPath)..."
    docker.exe login $($DockerSettings.RepositoryPath) -u $($DockerSettings.RepositoryUserName) -p $($DockerSettings.RepositoryPassword)
    Write-Host "Preparing Docker Container for Dynamics NAV..."
    $adminUsername = $env:USERNAME
    $adminPassword = Get-NAVPassword -Message "Enter password for user $adminUsername on the Docker Image" 
    $volume = "$($SetupParameters.Repository):C:\GIT"
    $rootPath = "$($SetupParameters.rootPath):C:\Host"
    $image = $SetupParameters.dockerImage
    docker.exe pull $image
    $DockerContainerId = docker.exe run -m 4G -v "$volume" -v "$rootPath" -e ACCEPT_EULA=Y -e username="$adminUsername" -e password="$adminPassword" -e auth=Windows -e Windowsauth=Y --detach $image
    Write-Host "Docker Container $DockerContainerId starting..."
    $Session = New-DockerSession -DockerContainerId $DockerContainerId
    $DockerContainerName = Get-DockerContainerName -Session $Session
    $BranchSettings.instanceName = "NAV" 
    $BranchSettings.databaseInstance = ""
    $BranchSettings.databaseServer = $DockerContainerName
    $BranchSettings.databaseName = "CRONUS"
    $BranchSettings.dockerContainerName = $DockerContainerName
    $BranchSettings.dockerContainerId = $DockerContainerId
    $BranchSettings.managementServicesPort = "7045"
    $BranchSettings.clientServicesPort = "7046"
    $result = Install-DockerAdvaniaGIT -Session $Session -SetupParameters $SetupParameters -BranchSettings $BranchSettings 

    $WaitForHealty = $true
    $LoopNo = 1
    while ($WaitForHealty -and $LoopNo -lt 20) {        
        $dockerContainer = Get-DockerContainers | Where-Object -Property Id -ieq $DockerContainerName
        Write-Host "Container status: $($dockerContainer.Status)..."
        $WaitForHealty = $dockerContainer.Status -match "(health: starting)"
        if ($WaitForHealty) { Start-Sleep -Seconds 10 }
        $LoopNo ++
    }
    if (!($dockerContainer.Status -match "(healthy)")) {
        Write-Error "Container $DockerContainerName unable to start !" -ErrorAction Stop
    }
    Update-BranchSettings -BranchSettings $BranchSettings
    Remove-PSSession -Session $Session 
}
