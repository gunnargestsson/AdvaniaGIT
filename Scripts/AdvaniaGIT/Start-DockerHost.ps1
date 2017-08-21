function Start-DockerHost
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters
    )

    $DockerHostName = (Get-RunningDockerHosts | Where-Object -Property Image -EQ $SetupParameters.dockerImage).ContainerId
    if (!$DockerHostName) {
        $DockerPath = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"
        & (Join-Path (Split-Path $PSScriptRoot -Parent) "RemoteManagement\Get-NAVPassword.ps1")
        $password = Get-NAVPassword -Message "Enter password for Docker Image" 
        $user = $env:USERNAME
        $params="run -m 4G -e ACCEPT_EULA=Y -e username=$user -e password=$password -e Windowsauth=Y $($SetupParameters.dockerImage)"
        Start-Process -FilePath $DockerPath -ArgumentList $params
        Start-Sleep -Seconds 30
        $DockerHostName = (Get-RunningDockerHosts | Where-Object -Property Image -EQ $SetupParameters.dockerImage).ContainerId
    }
}
