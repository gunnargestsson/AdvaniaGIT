function Get-DockerContainerConfiguration
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DockerContainerName
    )
                
    $DockerConfig = Docker.exe inspect $DockerContainerName | Out-String | ConvertFrom-Json
    return $DockerConfig
}
