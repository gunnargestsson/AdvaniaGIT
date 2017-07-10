Function Resume-NAVRemoteInstanceDataUpgrade {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )
    PROCESS 
    {
        Write-Host "Starting Data Upgrade on $($SelectedInstance.HostName):"
        Invoke-Command -Session $Session -ScriptBlock `
            {
                param([string] $InstanceName)
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                $Tenants = Get-NAVTenant -ServerInstance $InstanceName
                foreach ($Tenant in $Tenants) {
                    Write-Host "Resuming Data Upgrade for tenant $($Tenant.Id)..."
                    Resume-NAVDataUpgrade -Tenant $Tenant.Id -ServerInstance $InstanceName 
                }
                UnLoad-InstanceAdminTools
            } -ArgumentList $SelectedInstance.ServerInstance
        $anyKey = Read-Host "Press enter to continue..."
    }    
}
