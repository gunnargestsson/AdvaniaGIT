Function New-NAVDeploymentRemoteClickOnceSite {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    {
        if ($SelectedTenant.CustomerName -eq "") {
            Write-Host -ForegroundColor Red "Customer Name not configured.  Configure with Tenant Settings."
            break
        } elseif ($SelectedTenant.ClickOnceHost -eq "") {
            Write-Host -ForegroundColor Red "ClickOnce Host not configured.  Configure with Tenant Settings."
            break
        } elseif (!(Resolve-DnsName -Name $SelectedTenant.ClickOnceHost -ErrorAction SilentlyContinue)) {
            Write-Host -ForegroundColor Red "Host $($SelectedTenant.ClickOnceHost) not found in Dns!"
            break
        }
        Write-Host "Building ClickOnce Site for $($SelectedTenant.CustomerName)..."

        $RemoteConfig = Get-NAVRemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*ClickOnce*") {
                Write-Host "Updating $($RemoteComputer.HostName)..."
                $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN 
                # Prepare and Clean Up      
                Remove-NAVRemoteClickOnceSite -Session $Session -SelectedTenant $SelectedTenant  

                # Do some tests and import modules
                Prepare-NAVRemoteClickOnceSite -Session $Session -RemoteComputer $RemoteComputer 

                # Create the ClickOnce Site
                New-NAVRemoteClickOnceSite -Session $Session -SelectedInstance $SelectedInstance -SelectedTenant $SelectedTenant -ClickOnceApplicationName $Remotes.ClickOnceApplicationName -ClickOnceApplicationPublisher $Remotes.ClickOnceApplicationPublisher -ClientSettings $RemoteComputer.ClientSettings

                Remove-PSSession -Session $Session 
            }
        }
    }
}