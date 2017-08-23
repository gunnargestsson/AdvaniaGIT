function Start-DockerContainer
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings
    )

    $adminUsername = $env:USERNAME
    & (Join-Path (Split-Path $PSScriptRoot -Parent) "RemoteManagement\Get-NAVPassword.ps1")
    $adminPassword = Get-NAVPassword -Message "Enter password for user $adminUsername on the Docker Image" 
    $DockerSettings = Get-DockerSettings 
    docker login $($DockerSettings.RepositoryPath) -u $($DockerSettings.RepositoryUserName) -p $($DockerSettings.RepositoryPassword)
    $volume = "$($SetupParameters.Repository):C:\GIT"
    $image = $SetupParameters.dockerImage
    $DockerContainerId = docker run -m 4G -v "$volume" -e ACCEPT_EULA=Y -e username="$adminUsername" -e password="$adminPassword" -e Windowsauth=Y -e ClickOnce=Y --detach $image
    $Session = New-DockerSession -DockerContainerId $DockerContainerId
    $DockerContainerName = Get-DockerContainerName -Session $Session
    $BranchSettings.instanceName = "NAV" 
    $BranchSettings.databaseInstance = ""
    $BranchSettings.databaseServer = $DockerContainerName
    $BranchSettings.databaseName = "CRONUS"
    $BranchSettings.dockerContainerName = $DockerContainerName
    $BranchSettings.dockerContainerId = $DockerContainerId    
    $result = Install-DockerAdvaniaGIT -Session $Session -SetupParameters $SetupParameters -BranchSettings $BranchSettings 

    $WaitForHealty = $true
    $LoopNo = 1
    while ($WaitForHealty -and $LoopNo -lt 20) {        
        $dockerContainers = Get-RunningDockerContainers | Where-Object -Property Id -ieq $DockerContainerName
        Write-Host "Container status: $($dockerContainers.Status)..."
        $WaitForHealty = $dockerContainers.Status -match "(health: starting)"
        if ($WaitForHealty) { Start-Sleep -Seconds 10 }
        $LoopNo ++
    }
    if (!($dockerContainers.Status -match "(healthy)")) {
        Write-Error "Container $DockerContainerName unable to start !" -ErrorAction Stop
    }
    Update-BranchSettings -BranchSettings $BranchSettings
    Remove-PSSession -Session $Session 
}
