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
        $menuItems | Format-Table -Property No, UserName, FullName, AuthenticationEmail, LicenseType, State -AutoSize 
        $input = Read-Host "Please select user number (0 = exit, n = new user)"
        switch ($input) {
            '0' { break }
            'n' {
                    try {
                        $NewUser = New-NAVRemoteInstanceTenantUser -Session $Session -SelectedTenant $SelectedTenant
                        Write-Host "User $($NewUser.UserName) created with password $($NewUser.Password)"
                    }
                    catch {
                        Write-Host -ForegroundColor Red "Failed to create new users!"
                    }
                    finally {
                        $anyKey = Read-Host "Press enter to continue..."
                    }
                }
            default {
                $selectedUser = $menuItems | Where-Object -Property No -EQ $input                
                if ($selectedUser) {
                    do {
                        Clear-Host
                        For ($i=0; $i -le 10; $i++) { Write-Host "" }
                        $selectedUser | Format-Table -Property UserName,FullName, AuthenticationEmail, LicenseType, State  -AutoSize 
                        $input = Read-Host "Please select action:`
    0 = exit, `
    1 = reset password, `
    2 = update, `
    3 = remove, `
    Action: "

                        switch ($input) {
                            '0' { break }
                            '1' { 
                                    try {
                                        $NewPassword = Set-NAVRemoteInstanceTenantUserPassword -Session $Session -SelectedTenant $SelectedTenant -UserName $selectedUser.UserName
                                        Write-Host "Password for user $($selectedUser.UserName) changed to $($NewPassword)"
                                    }
                                    catch {
                                        Write-Host -ForegroundColor Red "Error updating password for $($selectedUser.UserName)"
                                    }
                                    finally {
                                        $anyKey = Read-Host "Press enter to continue..."
                                    }
                                }
                            '2' { 
                                    try {
                                        $UpdatedUser = Set-NAVRemoteInstanceTenantUser -Session $Session -SelectedTenant $SelectedTenant -SelectedUser $selectedUser
                                        Write-Host "User $($selectedUser.UserName) updated"
                                    }
                                    catch {
                                        Write-Host -ForegroundColor Red "Error updating user $($selectedUser.UserName)"
                                    }
                                    finally {
                                        $anyKey = Read-Host "Press enter to continue..."
                                    }
                                }
                            '3' { 
                                    try {
                                        $UpdatedUser = Remove-NAVRemoteInstanceTenantUser -Session $Session -SelectedTenant $SelectedTenant -SelectedUser $selectedUser
                                        Write-Host "User $($selectedUser.UserName) removed"
                                    }
                                    catch {
                                        Write-Host -ForegroundColor Red "Error removing user $($selectedUser.UserName)"
                                    }
                                    finally {
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
}