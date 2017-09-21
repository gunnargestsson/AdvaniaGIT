Function Start-NAVRemoteInstanceForceSync {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstances
    )
    PROCESS 
    {
        # Invoke the "same" command on the remote machine
        Foreach ($selectedInstance in $SelectedInstances) {
            $instanceName = $selectedInstance.ServerInstance
            Invoke-Command -Session $Session -ScriptBlock `
                {
                    param([string] $InstanceName)
                    Load-InstanceAdminTools -SetupParameters $SetupParameters
                    foreach ($Tenant in Get-NAVTenant -ServerInstance $InstanceName) {
                        Write-Host "Running Focer Sync for $($Tenant.Id)..."
                        Sync-NAVTenant -ServerInstance $InstanceName -Tenant $Tenant.Id -Mode ForceSync -Force
                    }
                    UnLoad-InstanceAdminTools
                } -ArgumentList $instanceName            
            Remove-PSSession -Session $Session
        }
    }    
}
