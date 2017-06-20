Function Set-NAVRemoteInstanceTenantUserPassword {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$UserName
    )
    PROCESS 
    {
        $NewPassword = Get-NewUserPassword 
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param([String]$ServerInstance, [String]$TenantId,[String]$UserName, [String]$NewPassword)
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                Set-NAVServerUser -ServerInstance $ServerInstance -Tenant $TenantId -UserName $UserName -Password (ConvertTo-SecureString -String $NewPassword -AsPlainText -Force) -Force
                UnLoad-InstanceAdminTools
                Return $Users
            } -ArgumentList ($SelectedTenant.ServerInstance, $SelectedTenant.Id, $UserName, $NewPassword)
        $RemoteConfig = Get-RemoteConfig
        if ($SelectedTenant.PasswordPid -gt "" -and $RemoteConfig.PasswordStateAPIKey -gt "" -and $RemoteConfig.NAVSuperUser.ToUpper() -eq $UserName) {
            Write-Host "Need to update $($RemoteConfig.PasswordStateUrl)..."
        }
        Return $NewPassword
    }    
}