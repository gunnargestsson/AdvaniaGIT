Function Stop-NAVRemoteInstance {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstances
    )
    PROCESS 
    {        
        Invoke-Command -Session $Session -ScriptBlock `
            {
                param([PSObject]$SelectedInstances)
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                Foreach ($selectedInstance in $SelectedInstances) {
                    Write-Host "Stopping instance $($selectedInstance.ServerInstance)..."
                    Set-NAVServerInstance -ServerInstance $selectedInstance.ServerInstance -Stop
                }
                UnLoad-InstanceAdminTools                        
            } -ArgumentList $SelectedInstances 
    }    
}
