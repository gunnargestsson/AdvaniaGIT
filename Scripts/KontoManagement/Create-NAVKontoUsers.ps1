Function Create-NAVKontoUsers {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Accountant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$TenantConfig
    )

    $RemoteConfig = Get-NAVRemoteConfig
    $Credential = Get-NAVKontoRemoteCredentials
    $Session = Get-NAVKontoRemoteSession -Provider $Provider

    foreach ($DefaultUser in $Provider.DefaultUsers) {
        if ($Tenantconfig.UserList.Length -eq 0 -or !$Tenantconfig.UserList.Contains($DefaultUser.AuthenticationEmail)) {
            $user = New-NAVUserObject -UserName $DefaultUser.UserName -AuthenticationEMail $DefaultUser.AuthenticationEmail -FullName "NAV Yfirnotandi" 
            $password = Get-NewUserPassword
            New-NAVRemoteInstanceTenantUser -Session $Session -SelectedTenant $TenantConfig -User $user -NewPassword $password
            if ($User.UserName -ieq $RemoteConfig.NAVSuperUser) { 
                $Response = Set-NAVPasswordStateUser -Title $TenantConfig.name -UserName $User.UserName -FullName $User.FullName -Password $password
                $SelectedTenant = Get-NAVRemoteInstanceTenantSettings -Session $Session -SelectedTenant $TenantConfig 
                $SelectedTenant.PasswordID = $Response.PasswordID
                $RemoteTenantSettings = Set-NAVDeploymentRemoteInstanceTenantSettings -Session $Session -Credential $Credential -SelectedTenant $SelectedTenant -DeploymentName $Provider.Deployment 
            }
        }
    }

    foreach ($AccountantUser in $Accountant.Users) {
        if ($Tenantconfig.UserList.Length -eq 0 -or !$Tenantconfig.UserList.Contains($AccountantUser.AuthenticationEmail)) {
            $user = New-NAVUserObject -UserName ($AccountantUser.AuthenticationEmail.Split('@')[0]) -AuthenticationEMail $AccountantUser.AuthenticationEmail -FullName "NAV Bókari" 
            New-NAVRemoteInstanceTenantUser -Session $Session -SelectedTenant $TenantConfig -User $user -NewPassword (Get-NewUserPassword) 
        }
    }

    Remove-PSSession -Session $Session 
}