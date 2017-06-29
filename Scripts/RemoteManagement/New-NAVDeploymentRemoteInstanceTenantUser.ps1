Function New-NAVDeploymentRemoteInstanceTenantUser {
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
                $RemoteTenantSettings = Set-NAVDeploymentRemoteInstanceTenantSettings -Session $Session -Credential $Credential -SelectedTenant $SelectedTenant -DeploymentName $DeploymentName 
            }   
        }        
        New-NAVRemoteInstanceTenantUser -Session $Session -SelectedTenant $SelectedTenant -User $NewUser -NewPassword $NewPassword -ChangePasswordAtNextLogOn ($RemoteConfig.NAVSuperUser -ine $User.UserName)
        $NewUser | Add-Member -MemberType NoteProperty -Name Password -Value $NewPassword
        Return $NewUser
    }    
}