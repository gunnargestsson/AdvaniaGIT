Function Start-NAVRemoteInstance {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstances
    )
    PROCESS 
    {
        # Invoke the "same" command on the remote machine       
        Invoke-Command -Session $Session -ScriptBlock `
            {
                param([PSObject] $SelectedInstances)
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                Foreach ($selectedInstance in $SelectedInstances) {
                    Write-Host "Starting instance $($selectedInstance.ServerInstance)..."
                    $BranchSetting = @{"instanceName" = $selectedInstance.ServerInstance}
                    Enable-TcpPortSharingForNAVService -branchSetting $branchSetting
                    Enable-DelayedStartForNAVService -branchSetting $branchSetting
                    Set-NAVServerInstance -ServerInstance $selectedInstance.ServerInstance -Start
                }
                UnLoad-InstanceAdminTools
            } -ArgumentList $SelectedInstances
        
    }    
}
