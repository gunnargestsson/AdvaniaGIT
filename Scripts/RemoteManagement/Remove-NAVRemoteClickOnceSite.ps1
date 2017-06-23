Function Remove-NAVRemoteClickOnceSite {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    {
        Write-Host "Removing ClickOnce Site for $($SelectedTenant.CustomerName)..."
        $RemoteConfig = Get-RemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*ClickOnce*") {
                Write-Host "Updating $($RemoteComputer.HostName)..."
                if ($Session.ComputerName -eq $RemoteComputer.FQDN) {
                    $RemoteSession = $Session
                } else {
                    $RemoteSession = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN 
                }
                # Clean Up        
                Invoke-Command -Session $RemoteSession -ScriptBlock `
                    {
                        Param([PSObject]$SelectedTenant)

                        $ExistingWebSite = Get-Website -Name "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)"
                        if ($ExistingWebSite) {
                            Get-ChildItem "IIS:\SslBindings" | Where-Object -Property Sites -eq "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" | Remove-Item -Force
                            $ExistingWebSite | Remove-Website 
                            Remove-Item -Path $ExistingWebSite.PhysicalPath -Recurse -Force                            
                        }                           
                    } -ArgumentList $SelectedTenant -ErrorAction Stop

                if ($Session.ComputerName -ne $RemoteSession.ComputerName) { Remove-PSSession -Session $RemoteSession }
            }
        }
    }
}