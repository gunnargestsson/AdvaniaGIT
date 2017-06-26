Function Set-NAVRemoteInstanceTenantUser {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedUser
    )
    PROCESS 
    {
        $User = New-UserObject -UserName $SelectedUser.UserName -FullName $SelectedUser.FullName -AuthenticationEMail $SelectedUser.AuthenticationEMail -LicenseType $SelectedUser.LicenseType -State $SelectedUser.State
        $User = New-UserDialog -Message "Enter details on user." -User $User -UserNameNotEditable
        if ($User.OKPressed -ne 'OK') { Return $User }
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param(
                    [String]$ServerInstance,
                    [String]$TenantId,
                    [PSObject]$User)
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                $params = @{ 
                    ServerInstance = $ServerInstance
                    Tenant = $TenantId
                    UserName = $User.UserName
                    FullName = $User.FullName
                    AuthenticationEmail = $User.AuthenticationEmail
                    LicenseType = $User.LicenseType
                    State = $User.State }
                Set-NAVServerUser @params -Force
                UnLoad-InstanceAdminTools
            } -ArgumentList (
                $SelectedTenant.ServerInstance, 
                $SelectedTenant.Id, 
                $User )
        Return $User
    }    
}