Function Manage-NAVRemoteInstances {
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
        $menuItems = Load-NAVRemoteInstanceMenu -Credential $Credential -RemoteConfig $RemoteConfig -DeploymentName $DeploymentName -IncludeAllHosts
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, HostName, ServerInstance, DatabaseName, Multitenant, Version, State -AutoSize 
        $input = Read-Host "Please select instance number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedInstanceName = ($menuItems | Where-Object -Property No -EQ $input).ServerInstance
                $selectedInstance = $menuItems | Where-Object -Property ServerInstance -EQ $selectedInstanceName
                if ($selectedInstance) {
                    do {
                        Clear-Host
                        For ($i=0; $i -le 10; $i++) { Write-Host "" }
                        $selectedInstance | Format-Table -Property No, HostName, ServerInstance, DatabaseName, Multitenant, Version, State -AutoSize 
                        $input = Read-Host "Please select action:`
    0 = exit, `
    1 = force sync, `
    2 = normal sync, `
    3 = start, `
    4 = stop, `
    5 = event log, `
    6 = sessions, `
    Action: "
                        switch ($input) {
                            '0' { break }
                            '1' { 
                                    Start-NAVRemoteInstanceForceSync -Credential $Credential -SelectedInstances $selectedInstance
                                }
                            '2' {                                     
                                    Start-NAVRemoteInstanceSync -Credential $Credential -SelectedInstances $selectedInstance
                                }
                            '3' {
                                    Start-NAVRemoteInstance -Credential $Credential -SelectedInstances $selectedInstance
                                }
                            '4' {
                                    Stop-NAVRemoteInstance -Credential $Credential -SelectedInstances $selectedInstance
                                }
                            '5' {
                                    Get-NAVRemoteInstanceEvents -Credential $Credential -SelectedInstances $selectedInstance
                                }
                            '6' {                                 
                                    Get-NAVRemoteInstanceTenantSessions -Credential $Credential -SelectedInstance $selectedInstance
                                    $anyKey = Read-Host "Press enter to continue..."
                                }
                        }                    
                    }
                    until ($input -iin ('0'))
                }
            }
        }
                    
    }
    until ($input -ieq '0')
    
}