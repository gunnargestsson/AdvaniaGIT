function Remove-NAVDockerClientFolders
{
    $DockerSettings = Get-DockerSettings
    $newClientFolders = @()
    foreach ($ClientFolder in $DockerSettings.ClientFolders) {
        if (Test-Path $ClientFolder.clientFolderPath) {        
            $newClientFolders += $ClientFolder
        }
    }
    $DockerSettings.ClientFolders = $newClientFolders
    Update-DockerSettings -DockerSettings $DockerSettings   
}