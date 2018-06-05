function Get-DockerContainerConfiguration
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DockerContainerName
    )
         
    $DockerExists = Get-DockerContainers | Where-Object -Property Names -EQ $DockerContainerName
    if ($DockerExists) {
        $DockerConfig = Docker.exe inspect $DockerExists.Id | Out-String | ConvertFrom-Json
        return $DockerConfig
    }
}
