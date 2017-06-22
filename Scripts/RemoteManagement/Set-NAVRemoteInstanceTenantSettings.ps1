Function Set-NAVRemoteInstanceTenantSettings {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    {
        $RemoteConfig = Get-RemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {
                Write-Host "Updating $($RemoteComputer.HostName)..."
                if ($Session.ComputerName -eq $RemoteComputer.FQDN) {
                    $RemoteSession = $Session
                } else {
                    $RemoteSession = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN 
                }        
                $TenantSettings = Invoke-Command -Session $RemoteSession -ScriptBlock `
                    {
                        param([PSObject]$Tenant)
                        $TenantSettings = Update-TenantSettings -Tenant $Tenant
                        Return $TenantSettings
                    } -ArgumentList $SelectedTenant
                if ($Session.ComputerName -ne $RemoteSession.ComputerName) { Remove-PSSession -Session $RemoteSession }
            }
        }
        Return $TenantSettings
    }    
}