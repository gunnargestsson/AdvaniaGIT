function Get-DockerContainerConfiguration
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DockerContainerName
    )
         
    $DockerExists = Get-DockerContainers | Where-Object -Property Id -EQ $DockerContainerName
    if ($DockerExists) {
        $DockerConfig = Docker.exe inspect $DockerContainerName | Out-String | ConvertFrom-Json
        return $DockerConfig
    }
}
