Function New-NAVDeploymentRemoteClickOnceSites {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    {    
        Write-Host "Collecting Instances..."

        $RemoteConfig = Get-RemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName

        $Instances = Load-NAVRemoteInstanceMenu -Credential $Credential -RemoteConfig $RemoteConfig -DeploymentName $DeploymentName
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*ClickOnce*") {
                Write-Host "Updating $($RemoteComputer.HostName)..."
                $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN 

                # Do some tests and import modules
                Prepare-NAVRemoteClickOnceSite -Session $Session -RemoteComputer $RemoteComputer 

                Foreach ($SelectedInstance in $Instances) {
                    Foreach ($SelectedTenant in $SelectedInstance.TenantList) {
                        
                        # Prepare and Clean Up      
                        Remove-NAVRemoteClickOnceSite -Session $Session -SelectedTenant $SelectedTenant  

                        if ($SelectedTenant.CustomerName -gt "" -and $SelectedTenant.ClickOnceHost -gt "") {
                            Write-Host "Building ClickOnce Site for $($SelectedTenant.CustomerName)..."
                            # Create the ClickOnce Site
                            New-NAVRemoteClickOnceSite -Session $Session -SelectedInstance $SelectedInstance -SelectedTenant $SelectedTenant -ClickOnceApplicationName $Remotes.ClickOnceApplicationName -ClickOnceApplicationPublisher $Remotes.ClickOnceApplicationPublisher
                        }
                    }
                }
                Remove-PSSession -Session $Session 
            }
        }
    }
}