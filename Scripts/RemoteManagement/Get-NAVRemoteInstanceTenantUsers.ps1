Function Get-NAVRemoteInstanceTenantUsers {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
    PROCESS 
    {
        $Users = Invoke-Command -Session $Session -ScriptBlock `
            {
                param([String]$ServerInstance, [String]$TenantId)
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                $Users = Get-NAVServerUser -ServerInstance $ServerInstance -Tenant $TenantId
                UnLoad-InstanceAdminTools
                Return $Users
            } -ArgumentList ($SelectedTenant.ServerInstance, $SelectedTenant.Id)
        Return $Users
    }    
}