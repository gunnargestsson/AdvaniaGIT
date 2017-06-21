Function List-NAVRemoteInstances {
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
    6 = tenants `
    7 = development `
    8 = web client `
    9 = nav client `
    Action: "
                        switch ($input) {
                            '0' { break }
                            '1' { 
                                    ForceSync-NAVRemoteInstance -Credential $Credential -SelectedInstances $selectedInstance
                                }
                            '2' {                                     
                                    Sync-NAVRemoteInstance -Credential $Credential -SelectedInstances $selectedInstance
                                }
                            '3' {
                                    Start-NAVRemoteInstance -Credential $Credential -SelectedInstances $selectedInstance
                                }
                            '4' {
                                    Stop-NAVRemoteInstance -Credential $Credential -SelectedInstances $selectedInstance
                                }
                            '5' {
                                    Show-NAVRemoteInstanceEvents -Credential $Credential -SelectedInstances $selectedInstance
                                }
                            '6' {
                                    List-NAVRemoteInstanceTenants -Credential $Credential -SelectedInstance $selectedInstance[0]
                                }
                            '7' {
                                    Start-NAVRemoteDevelopment -SelectedInstance $selectedInstance[0]
                                }
                            '8' {
                                    if ($selectedInstance[0].Multitenant -eq "false") {
                                        Start-PasswordStateWebSite -PasswordId $selectedInstance.TenantList[0].PasswordId
                                        Start-NAVRemoteWebClient -SelectedInstance $selectedInstance[0]
                                    } else {
                                        Write-Host "Instance is multitenant, start client from tenant menu!" -ForegroundColor Red 
                                        $anyKey = Read-Host "Press enter to continue..."
                                    }
                                }
                            '9' {
                                    if ($selectedInstance[0].Multitenant -eq "false") {
                                        Start-PasswordStateWebSite -PasswordId $selectedInstance.TenantList[0].PasswordId
                                        Start-NAVRemoteWindowsClient -SelectedInstance $selectedInstance[0]
                                    } else {
                                        Write-Host "Instance is multitenant, start client from tenant menu!" -ForegroundColor Red 
                                        $anyKey = Read-Host "Press enter to continue..."
                                    }
                                }
                        }                    
                    }
                    until ($input -iin ('0', '1', '2', '3', '4', '5', '6', '7', '8', '8'))
                }
            }
        }
                    
    }
    until ($input -ieq '0')
    
}