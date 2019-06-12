Function Start-NAVRemoteInstanceDataUpgrade {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$SkipCompanyInitialization
    )
    PROCESS 
    {
        Write-Host "Starting Data Upgrade on $($SelectedInstance.HostName):"
        Invoke-Command -Session $Session -ScriptBlock `
            {
                param([string] $InstanceName, [switch]$SkipCompanyInitialization)
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                $Tenants = Get-NAVTenant -ServerInstance $InstanceName
                foreach ($Tenant in $Tenants) {
                    Write-Host "Starting Data Upgrade for tenant $($Tenant.Id)..."
                    $TenantSettings = Get-TenantSettings -SetupParameters $SetupParameters -Tenant $Tenant
                    if ($SkipCompanyInitialization) {
                        Start-NAVDataUpgrade -Tenant $Tenant.Id -ServerInstance $InstanceName -Language $TenantSettings.Language -FunctionExecutionMode Parallel -SkipCompanyInitialization -Force -SkipAppVersionCheck
                    } else {
                        Start-NAVDataUpgrade -Tenant $Tenant.Id -ServerInstance $InstanceName -Language $TenantSettings.Language -FunctionExecutionMode Parallel -Force -SkipAppVersionCheck
                    }
                }
                UnLoad-InstanceAdminTools
            } -ArgumentList ($SelectedInstance.ServerInstance, $SkipCompanyInitialization)
        $anyKey = Read-Host "Press enter to continue..."
    }    
}
