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
        $input = Read-Host "Please select instance number (0 = exit, + = Manage Services)"
        switch ($input) {
            '0' { break }
            '+' { Manage-NAVRemoteInstances -Credential $Credential -RemoteConfig $RemoteConfig -DeploymentName $DeploymentName }
            default {
                $selectedInstanceName = ($menuItems | Where-Object -Property No -EQ $input).ServerInstance
                $selectedInstance = $menuItems | Where-Object -Property ServerInstance -EQ $selectedInstanceName
                if ($selectedInstance) {
                    do {
                        Clear-Host
                        For ($i=0; $i -le 10; $i++) { Write-Host "" }
                        $selectedInstance | Format-Table -Property HostName, ServerInstance, DatabaseName, Multitenant, Version, State -AutoSize 
                        $input = Read-Host "Please select action:`
    0 = exit, `
    1 = List Tenants, `
    2 = List Instance Sessions, `
    3 = Start Development (finsql), `
    4 = Start Web Client, `
    5 = Start NAV Client, `
    6 = Start NAV Debugger, `
    Action: "
                        switch ($input) {
                            '0' { break }
                            '1' {
                                    List-NAVRemoteInstanceTenants -Credential $Credential -SelectedInstance $selectedInstance[0]
                                }
                            '2' {
                                    if ($selectedInstance[0].Multitenant -eq "false") {
                                        List-NAVRemoteInstanceSessions -Credential $Credential -SelectedInstance $selectedInstance[0]
                                    } else {
                                        Write-Host "Instance is multitenant, view sessions from tenant menu!" -ForegroundColor Red 
                                        $anyKey = Read-Host "Press enter to continue..."
                                    }                                    
                                }
                            '3' {
                                    Start-NAVRemoteDevelopment -SelectedInstance $selectedInstance[0]
                                }
                            '4' {
                                    if ($selectedInstance[0].Multitenant -eq "false") {
                                        Start-PasswordStateWebSite -PasswordId $selectedInstance.TenantList[0].PasswordId
                                        Start-NAVRemoteWebClient -SelectedInstance $selectedInstance[0]
                                    } else {
                                        Write-Host "Instance is multitenant, start client from tenant menu!" -ForegroundColor Red 
                                        $anyKey = Read-Host "Press enter to continue..."
                                    }
                                }
                            '5' {
                                    if ($selectedInstance[0].Multitenant -eq "false") {
                                        Start-PasswordStateWebSite -PasswordId $selectedInstance.TenantList[0].PasswordId
                                        Start-NAVRemoteWindowsClient -SelectedInstance $selectedInstance[0]
                                    } else {
                                        Write-Host "Instance is multitenant, start client from tenant menu!" -ForegroundColor Red 
                                        $anyKey = Read-Host "Press enter to continue..."
                                    }
                                }
                            '6' {
                                    if ($selectedInstance[0].Multitenant -eq "false") {
                                        Start-PasswordStateWebSite -PasswordId $selectedInstance.TenantList[0].PasswordId
                                        Start-NAVRemoteWindowsDebugger -SelectedInstance $selectedInstance[0]
                                    } else {
                                        Write-Host "Instance is multitenant, start client from tenant menu!" -ForegroundColor Red 
                                        $anyKey = Read-Host "Press enter to continue..."
                                    }
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