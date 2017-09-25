Function Start-NAVRemoteInstanceTenantsSync {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SelectedInstanceName
    )
    PROCESS 
    {
        # Invoke the "same" command on the remote machine
        Invoke-Command -Session $Session -ScriptBlock `
            {
                param([String] $SelectedInstanceName)
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                Get-NAVTenant -ServerInstance $SelectedInstanceName | Sync-NAVTenant -Mode Sync -Force                
                UnLoad-InstanceAdminTools
            } -ArgumentList $SelectedInstanceName
    }    
}
