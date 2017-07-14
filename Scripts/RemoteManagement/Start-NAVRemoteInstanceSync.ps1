Function Start-NAVRemoteInstanceSync {
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
                    $Results = Get-NAVTenant -ServerInstance $InstanceName | Sync-NAVTenant -Mode Sync -Force
                    UnLoad-InstanceAdminTools
                    Return $Results
                } -ArgumentList $instanceName
        }
    }    
}
