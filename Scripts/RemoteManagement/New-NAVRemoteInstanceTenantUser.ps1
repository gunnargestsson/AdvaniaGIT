Function New-NAVRemoteInstanceTenantUser {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
    PROCESS 
    {
        $RemoteConfig = Get-RemoteConfig
        $NewUser = New-UserDialog -Message "Enter details on new user." -User (New-UserObject)
        if ($NewUser.UserName -eq "") { Return $NewUser }   
        if ($NewUser.OKPressed -ne 'OK') { Return $NewUser }  
        $NewPassword = Get-NewUserPassword 
        if ($NewUser.UserName -ieq $RemoteConfig.NAVSuperUser) {
            if ($SelectedTenant.CustomerName -eq "") {
                Write-Host -ForegroundColor Red "Please complete the Tenant Settings before creating the administrative user!"
                break
            }
            if ($RemoteConfig.PasswordStateAPIKey -gt "") {
                $Response = Set-NAVPasswordStateUser -Title $SelectedTenant.CustomerName -UserName $NewUser.UserName -FullName $NewUser.FullName -Password $NewPassword
                $SelectedTenant.PasswordID = $Response.PasswordID
                $RemoteTenantSettings = Set-NAVRemoteInstanceTenantSettings -Session $Session -Credential $Credential -SelectedTenant $SelectedTenant -DeploymentName $DeploymentName 
            }   
        }        

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
                if ($ChangePasswordAtNextLogOn) { $params.ChangePasswordAtNextLogOn = $true }
                New-NAVServerUser @params -Force
                New-NAVServerUserPermissionSet -ServerInstance $ServerInstance -Tenant $TenantId -UserName $User.UserName -PermissionSetId SUPER
                UnLoad-InstanceAdminTools
            } -ArgumentList (
                $SelectedTenant.ServerInstance, 
                $SelectedTenant.Id, 
                $NewUser, 
                $NewPassword, 
                ($RemoteConfig.NAVSuperUser.ToUpper() -eq $User.UserName))
        
        $NewUser | Add-Member -MemberType NoteProperty -Name Password -Value $NewPassword
        Return $NewUser
    }    
}