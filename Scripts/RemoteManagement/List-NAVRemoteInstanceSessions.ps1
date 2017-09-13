Function List-NAVRemoteInstanceSessions {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstances,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
   
    do {
        Write-Host "Loading Remote Session Menu..."  
        $menuItems = @()
        foreach ($SelectedInstance in $SelectedInstances) {
            $menuItems += Load-NAVRemoteInstanceSessionsMenu -Credential $Credential -SelectedInstance $SelectedInstance -SelectedTenant $SelectedTenant
        }
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, ServerInstanceName, ServerComputerName, UserID, ClientType, ClientComputerName, LoginDatetime -AutoSize 
        $input = Read-Host "Please select Session number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedSession = $menuItems | Where-Object -Property No -EQ $input                
                if ($selectedSession) {
                    do {
                        Clear-Host
                        For ($i=0; $i -le 10; $i++) { Write-Host "" }
                        $selectedSession | Format-Table -Property ServerInstanceName, ServerComputerName, UserID, ClientType, ClientComputerName, LoginDatetime -AutoSize 
                        $input = Read-Host "Please select action:`
    0 = Exit, `
    1 = Start NAV Debugger `
    2 = Start NAV Client `
    Action: "

                        switch ($input) {
                            '0' { break }
                            '1' {                                    
                                    if ($SelectedTenant) {
                                        Start-NAVPasswordStateWebSite -PasswordId $SelectedTenant.PasswordId
                                        Start-NAVRemoteWindowsDebugger -SelectedInstance $selectedInstance -Server $selectedSession.PSComputerName -TenantId $SelectedTenant.Id
                                    } else {
                                        Start-NAVPasswordStateWebSite -PasswordId $selectedInstance.TenantList[0].PasswordId
                                        Start-NAVRemoteWindowsDebugger -SelectedInstance $selectedInstance -Server $selectedSession.PSComputerName 
                                    }
                                }
                            '2' {                                    
                                    if ($SelectedTenant) {
                                        Start-NAVPasswordStateWebSite -PasswordId $SelectedTenant.PasswordId
                                        Start-NAVRemoteWindowsClient -SelectedInstance $selectedInstance -Server $selectedSession.PSComputerName -TenantId $SelectedTenant.Id
                                    } else {
                                        Start-NAVPasswordStateWebSite -PasswordId $selectedInstance.TenantList[0].PasswordId
                                        Start-NAVRemoteWindowsClient -SelectedInstance $selectedInstance -Server $selectedSession.PSComputerName 
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