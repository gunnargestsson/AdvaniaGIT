Function New-NAVRemoteInstanceTenantUser {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$User,                    
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$NewPassword,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$ChangePasswordAtNextLogOn
    )
    PROCESS 
    {
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param(
                    [String]$ServerInstance,
                    [String]$TenantId,
                    [PSObject]$User,                    
                    [String]$NewPassword,
                    [Switch]$ChangePasswordAtNextLogOn)
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                $params = @{ 
                    ServerInstance = $ServerInstance
                    Tenant = $TenantId
                    UserName = $User.UserName
                    FullName = $User.FullName
                    AuthenticationEmail = $User.AuthenticationEmail
                    LicenseType = $User.LicenseType
                    State = $User.State
                    Password = (ConvertTo-SecureString -String $NewPassword -AsPlainText -Force) }
                if ($ChangePasswordAtNextLogOn) {
                    New-NAVServerUser @params -Force -ChangePasswordAtNextLogOn
                } else {
                    New-NAVServerUser @params -Force
                }
                New-NAVServerUserPermissionSet -ServerInstance $ServerInstance -Tenant $TenantId -UserName $User.UserName -PermissionSetId SUPER
                UnLoad-InstanceAdminTools
            } -ArgumentList (
                $SelectedTenant.ServerInstance, 
                $SelectedTenant.Id, 
                $User,                    
                $NewPassword,
                $ChangePasswordAtNextLogOn)
    }    
}