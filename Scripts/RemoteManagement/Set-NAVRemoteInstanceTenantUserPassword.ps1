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
        $TenantSettings = Get-NAVRemoteInstanceTenantSettings -Session $Session -SelectedTenant $SelectedTenant
        if ($TenantSettings.PasswordId -gt "" -and $RemoteConfig.PasswordStateAPIKey -gt "" -and $RemoteConfig.NAVSuperUser -ieq $UserName) {
            Set-NAVPasswordStateId -PasswordId $SelectedTenant.PasswordId -Password $NewPassword
        }
        Return $NewPassword
    }    
}