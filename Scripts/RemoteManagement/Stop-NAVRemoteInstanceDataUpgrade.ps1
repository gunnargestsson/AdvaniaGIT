Function Stop-NAVRemoteInstanceDataUpgrade {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )
    PROCESS 
    {
        Write-Host "Stopping Data Upgrade on $($SelectedInstance.HostName):"
        Invoke-Command -Session $Session -ScriptBlock `
            {
                param([string] $InstanceName)
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                $Tenants = Get-NAVTenant -ServerInstance $InstanceName
                foreach ($Tenant in $Tenants) {
                    Write-Host "Stopping Data Upgrade for tenant $($Tenant.Id)..."
                    Stop-NAVDataUpgrade -Tenant $Tenant.Id -ServerInstance $InstanceName -Force
                }
                UnLoad-InstanceAdminTools
            } -ArgumentList $SelectedInstance.ServerInstance
        $anyKey = Read-Host "Press enter to continue..."
    }    
}
