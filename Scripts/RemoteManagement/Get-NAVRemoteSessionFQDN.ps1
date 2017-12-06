Function Get-NAVRemoteSessionFQDN {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$ServerInstanceSession
    )

    $RemoteConfig = Get-NAVRemoteConfig
    foreach ($Remote in $RemoteConfig.Remotes) {
        foreach ($Host in $Remote.Hosts) {
            if ($Host.HostName -ieq $ServerInstanceSession.ServerComputerName) {
                return $Host.FQDN
            }
        }
    }
}