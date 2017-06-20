Function Configure-NAVRemoteInstanceTenantUsers {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
    PROCESS
    {
        do {
        Write-Host "Loading Remote Tenant User Menu..."   
        $menuItems = Load-NAVRemoteInstanceTenantUsersMenu -Session $Session  -SelectedTenant $SelectedTenant
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, UserName, AuthenticationEmail, LicenseType, State -AutoSize 
        $input = Read-Host "Please select user number (0 = exit, n = new user)"
        switch ($input) {
            '0' { break }
            'n' {
                    $NewUser = New-NAVRemoteInstanceTenantUser -Session $Session -SelectedTenant $SelectedTenant
                    Write-Host "User $(NewUser.UserName) created with password $($NewUser.Password)"
                    $anyKey = Read-Host "Press enter to continue..."               
                }
            default {
                $selectedUser = $menuItems | Where-Object -Property No -EQ $input                
                if ($selectedUser) {
                    do {
                        Clear-Host
                        For ($i=0; $i -le 10; $i++) { Write-Host "" }
                        $selectedUser | Format-Table -Property No, UserName, AuthenticationEmail, LicenseType, State  -AutoSize 
                        $input = Read-Host "Please select action:`
    0 = exit, `
    1 = reset password, `
    2 = toggle enable/disable, `
    3 = toggle license type, `
    Action: "

                        switch ($input) {
                            '0' { break }
                            '1' { 
                                    $NewPassword = Set-NAVRemoteInstanceTenantUserPassword -Session $Session -SelectedTenant $SelectedTenant -UserName $selectedUser.UserName
                                    Write-Host "Password for user $($selectedUser.UserName) changed to $($NewPassword)"
                                    $anyKey = Read-Host "Press enter to continue..."
                                }
                        }                    
                    }
                    until ($input -iin ('0', '1'))
                }
            }
        }
                    
    }
    until ($input -ieq '0')
    }
}