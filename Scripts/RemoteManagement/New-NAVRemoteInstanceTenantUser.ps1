Function New-NAVRemoteInstanceTenantUser {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
    PROCESS 
    {
        $NewUserName = Request-UserInput -Message "New User Name"
        $NewPassword = Get-NewUserPassword 
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param([String]$ServerInstance, [String]$TenantId,[String]$UserName, [String]$NewPassword, [Switch]$ChangePasswordAtNextLogOn)
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                if ($ChangePasswordAtNextLogOn) {
                    New-NAVServerUser -ServerInstance $ServerInstance -Tenant $TenantId -UserName $UserName -Password (ConvertTo-SecureString -String $NewPassword -AsPlainText -Force) -ChangePasswordAtNextLogOn -Force
                } else {
                    New-NAVServerUser -ServerInstance $ServerInstance -Tenant $TenantId -UserName $UserName -Password (ConvertTo-SecureString -String $NewPassword -AsPlainText -Force) -Force
                }
                UnLoad-InstanceAdminTools
                Return $Users
            } -ArgumentList ($SelectedTenant.ServerInstance, $SelectedTenant.Id, $NewUserName, $NewPassword, ($RemoteConfig.NAVSuperUser.ToUpper() -eq $UserName))

        $NewUser = New-Object -TypeName PSObject
        $NewUser | Add-Member -MemberType NoteProperty -Name UserName -Value $NewUserName
        $NewUser | Add-Member -MemberType NoteProperty -Name Password -Value $NewPassword
        Return $NewUser
    }    
}