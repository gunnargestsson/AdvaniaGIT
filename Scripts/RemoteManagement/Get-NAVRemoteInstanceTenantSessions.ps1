Function Get-NAVRemoteInstanceTenantSessions {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
    PROCESS 
    {

        if ($SelectedTenant) { 
            $TenantId = $SelectedTenant.Id 
        } else {
            $TenantId = 'default'
        }

        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param([String]$ServerInstance, [String]$TenantId)
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                $Sessions = Get-NAVServerSession -ServerInstance $ServerInstance -Tenant $TenantId 
                UnLoad-InstanceAdminTools
                return $Sessions
            } -ArgumentList ($SelectedInstance.ServerInstance, $TenantId)
        return $Result
    }    
}