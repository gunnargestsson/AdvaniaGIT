Function List-NAVRemoteInstanceTenants {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )
   
    do {
        Write-Host "Loading Remote Tenant Menu..."   
        $menuItems = Load-NAVRemoteInstanceTenantsMenu -Credential $Credential -SelectedInstance $SelectedInstance
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, Id, DatabaseName, CustomerName, LicenseNo, PasswordPid, ClickOnceHost, State -AutoSize 
        $input = Read-Host "Please select tenant number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedTenant = $menuItems | Where-Object -Property No -EQ $input                
                if ($selectedTenant) {
                    do {
                        Clear-Host
                        For ($i=0; $i -le 10; $i++) { Write-Host "" }
                        $selectedTenant | Format-Table -Property Id, DatabaseName, CustomerName, LicenseNo, PasswordPid, ClickOnceHost, State -AutoSize 
                        $input = Read-Host "Please select action:`
    0 = exit, `
    1 = nav client `
    2 = web client `
    Action: "

                        switch ($input) {
                            '0' { break }
                            '1' {
                                    Start-PasswordStateWebSite -PasswordId $selectedTenant.PasswordId
                                    Start-NAVRemoteWebClient -SelectedInstance $selectedInstance -TenantId $selectedTenant.Id
                                }
                            '2' {
                                    Start-PasswordStateWebSite -PasswordId $selectedTenant.PasswordId
                                    Start-NAVRemoteWindowsClient -SelectedInstance $selectedInstance -TenantId $selectedTenant.Id
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