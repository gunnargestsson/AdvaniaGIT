Function New-NAVRemoteWebInstances {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    {    
        Write-Host "Loading Instances for $DeploymentName..."

        $RemoteConfig = Get-NAVRemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName

        $Instances = Load-NAVRemoteInstanceMenu -Credential $Credential -RemoteConfig $RemoteConfig -DeploymentName $DeploymentName
        $Instances = Get-NAVSelectedInstances -ServerInstances $Instances
        if (!$Instances) { break }

        Foreach ($RemoteComputer in $Remotes.Hosts) {
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*Web*") {
                Write-Host "Updating $($RemoteComputer.HostName)..."
                $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN 
                Set-NAVRemoteWebClientBinding -Session $Session -ServicesCertificateThumbprint $Instances[0].ServicesCertificateThumbprint
                Foreach ($SelectedInstance in $Instances) {
    
                    # Remove old Web Instance
                    Remove-NAVRemoteWebInstance -Session $Session -SelectedInstance $SelectedInstance 
                                               
                    # Create the Web Instance
                    New-NAVRemoteWebInstance -Session $Session -SelectedInstance $SelectedInstance -ClientSettings $RemoteComputer.ClientSettings
                }
                Remove-PSSession -Session $Session 
            }
        }
        $anyKey = Read-Host "Press enter to continue..."
    }
}