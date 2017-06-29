Function Remove-NAVDeploymentRemoteInstance {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    { 
        $ConfirmedServerInstance = Read-Host "Type name of the server instance to delete"
        if ($ConfirmedServerInstance -ine $SelectedInstance.ServerInstance) { break }
        $SelectedTenant = Get-NAVRemoteInstanceDefaultTenant -SelectedInstance $SelectedInstance
        $RemoteConfig = Get-RemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        if ($SelectedTenant.ClickOnceHost -gt "") {
            Remove-AzureDnsZoneRecordSet -DnsHostName $SelectedTenant.ClickOnceHost
        }
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            Write-Host "Updating $($RemoteComputer.HostName)..."
            $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN         
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*ClickOnce*") {
                # Prepare and Clean Up      
                Remove-NAVRemoteClickOnceSite -Session $Session -SelectedTenant $SelectedTenant  
            }
            if ($Roles -like "*Web*") {
                # Remove old Web Instance
                Remove-NAVRemoteWebInstance -Session $Session -SelectedInstance $SelectedInstance 
            }
            if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {
                Remove-NAVRemoteInstance -Session $Session -ServerInstance $SelectedInstance.ServerInstance 
            }
            Remove-PSSession $Session
        }
    }    
}