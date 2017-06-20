Function Configure-NAVRemoteInstanceTenants {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )

    do {
        Write-Host "Loading Remote Tenant Menu..."   
        $Session = Create-NAVRemoteSession -Credential $Credential -HostName $SelectedInstance.PSComputerName
        $menuItems = Load-NAVRemoteInstanceTenantsMenu -Credential $Credential -SelectedInstance $SelectedInstance
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, Id, DatabaseName, CustomerName, LicenseNo, PasswordPid, State -AutoSize 
        $input = Read-Host "Please select tenant number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedTenant = $menuItems | Where-Object -Property No -EQ $input                
                if ($selectedTenant) {                    
                    do {
                        Clear-Host
                        For ($i=0; $i -le 10; $i++) { Write-Host "" }
                        $selectedTenant | Format-Table -Property No, Id, DatabaseName, CustomerName, LicenseNo, PasswordPid, State -AutoSize 
                        $input = Read-Host "Please select action:`
    0 = exit, `
    1 = users, `
    2 = ClickOnce, `
    Action: "

                        switch ($input) {
                            '0' { break }
                            '1' { Configure-NAVRemoteInstanceTenantUsers -Session $Session -SelectedTenant $selectedTenant }
                        }                    
                    }
                    until ($input -iin ('0', '1'))
                }
            }
        }                   
    Remove-PSSession -Session $Session
    }
    until ($input -ieq '0')
    
}