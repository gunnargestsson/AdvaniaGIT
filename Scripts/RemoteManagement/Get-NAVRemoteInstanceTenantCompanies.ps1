Function Get-NAVRemoteInstanceTenantCompanies {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
    PROCESS 
    {
        $Companies = Invoke-Command -Session $Session -ScriptBlock `
            {
                param([String]$ServerInstance, [String]$TenantId)
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                $Companies = Get-NAVCompany -ServerInstance $ServerInstance -Tenant $TenantId
                UnLoad-InstanceAdminTools
                Return $Companies
            } -ArgumentList ($SelectedTenant.ServerInstance, $SelectedTenant.Id)
        Return $Companies
    }    
}