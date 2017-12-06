Function Get-NAVKontoRemoteSession {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider
    )

    $RemoteConfig = Get-NAVRemoteConfig
    $Credential = Get-NAVKontoRemoteCredentials 

    if (!$Credential.UserName -or !$Credential.Password) {
        Write-Host -ForegroundColor Red "Credentials required!"
        break
    }

    $Hosts = ($RemoteConfig.Remotes | Where-Object -Property Deployment -EQ $Provider.Deployment).Hosts
    Foreach ($Host in $Hosts) {
        $Hostname = $Host.Hostname
        $FQDN = $Host.FQDN
        $Roles = $Host.Roles
        if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {
            Write-Verbose "Connect to $FQDN..."
            $Session = New-NAVRemoteSession -Credential $Credential -HostName $FQDN 
            return $Session
        }
    }
}
