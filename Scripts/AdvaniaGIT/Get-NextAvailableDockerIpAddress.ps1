Function Get-NextAvailableDockerIpAddress
{
    $DockerSettings = Get-DockerSettings 
    if ([string]::IsNullOrEmpty($DockerSettings.DockerHostIPNetwork)) {
        Write-Host -ForegroundColor Red "Docker Ip Network is not configured in Docker Settings"
    } else {
        $addresses = 3..254
        foreach ($address in $addresses) {
            $DockerIp = "$($DockerSettings.DockerHostIpNetwork)$($address)"
            if (!(Test-Connection -ComputerName $DockerIp -Quiet -Count 1)) {
                return $DockerIp
            }
        }
    }

}
