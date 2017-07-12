Function List-NAVRemoteInstanceTenants {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
   
    do {
        Write-Host "Loading Remote Tenant Menu..."   
        $menuItems = Load-NAVRemoteInstanceTenantsMenu -SelectedInstance $SelectedInstance
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, Id, DatabaseName, CustomerName, LicenseNo, PasswordId, ClickOnceHost, State -AutoSize 
        $input = Read-Host "Please select tenant number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedTenant = $menuItems | Where-Object -Property No -EQ $input                
                if ($selectedTenant) {
                    do {
                        Clear-Host
                        For ($i=0; $i -le 10; $i++) { Write-Host "" }
                        $selectedTenant | Format-Table -Property Id, DatabaseName, CustomerName, LicenseNo, PasswordId, ClickOnceHost, State -AutoSize 
                        $input = Read-Host "Please select action:`
    0 = exit, `
    1 = Start Web Client `
    2 = Start NAV Client `
    3 = Start NAV Debugger `
    4 = List NAV Sessions
    Action: "

                        switch ($input) {
                            '0' { break }
                            '1' {
                                    Start-NAVPasswordStateWebSite -PasswordId $selectedTenant.PasswordId
                                    Start-NAVRemoteWebClient -SelectedInstance $selectedInstance -TenantId $selectedTenant.Id
                                }
                            '2' {
                                    Start-NAVPasswordStateWebSite -PasswordId $selectedTenant.PasswordId
                                    Start-NAVRemoteWindowsClient -SelectedInstance $selectedInstance -TenantId $selectedTenant.Id
                                }
                            '3' {
                                    Start-NAVPasswordStateWebSite -PasswordId $selectedTenant.PasswordId
                                    Start-NAVRemoteWindowsDebugger -SelectedInstance $selectedInstance -TenantId $selectedTenant.Id
                                }
                            '4' {
                                   List-NAVRemoteInstanceSessions -Credential $Credential -SelectedInstance $selectedInstance -SelectedTenant $SelectedTenant
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