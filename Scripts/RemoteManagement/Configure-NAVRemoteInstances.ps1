Function Configure-NAVRemoteInstances {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$RemoteConfig,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
        
    do {
        Write-Host "Loading Remote Instance Menu..."   
        $menuItems = Load-NAVRemoteInstanceMenu -Credential $Credential -RemoteConfig $RemoteConfig -DeploymentName $DeploymentName
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, ServerInstance, DatabaseName, Multitenant, Version, State -AutoSize 
        $input = Read-Host "Please select instance number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedInstance = $menuItems | Where-Object -Property No -EQ $input
                if ($selectedInstance) {
                    Configure-NAVRemoteInstanceTenants -Credential $Credential -SelectedInstance $selectedInstance
                }
            }
        }
                    
    }
    until ($input -ieq '0')
    
}