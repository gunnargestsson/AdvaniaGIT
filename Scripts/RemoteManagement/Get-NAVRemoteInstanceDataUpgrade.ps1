Function Get-NAVRemoteInstanceDataUpgrade {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Bool]$Details
    )
    PROCESS 
    {
        Write-Host "Starting Data Upgrade on $($SelectedInstance.HostName):"
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param([string]$InstanceName, [Bool]$Details)
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                $Tenants = Get-NAVTenant -ServerInstance $InstanceName
                $Result = @()
                foreach ($Tenant in $Tenants) {                    
                    if ($Details) {
                        Write-Host "Getting Detailed Data Upgrade status for tenant $($Tenant.Id)..."
                        $Result += Get-NAVDataUpgrade -Tenant $Tenant.Id -ServerInstance $InstanceName -Detailed
                    } else {
                        Write-Host "Getting Data Upgrade status for tenant $($Tenant.Id)..."
                        $Result += Get-NAVDataUpgrade -Tenant $Tenant.Id -ServerInstance $InstanceName 
                    }
                }
                UnLoad-InstanceAdminTools
                Return $Result
            } -ArgumentList ($SelectedInstance.ServerInstance, $Details)
        $Result | Out-GridView
    }    
}
