Function Start-NAVRemoteInstanceForceSync {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstances
    )
    PROCESS 
    {
        # Invoke the "same" command on the remote machine
        Foreach ($selectedInstance in $SelectedInstances) {
            $instanceName = $selectedInstance.ServerInstance
            Write-Host "Force-syncronizing Tenants for $instanceName on $($SelectedInstance.HostName):"
            $Session = New-NAVRemoteSession -Credential $Credential -HostName $SelectedInstance.PSComputerName 
            Invoke-Command -Session $Session -ScriptBlock `
                {
                    param([string] $InstanceName)
                    Load-InstanceAdminTools -SetupParameters $SetupParameters
                    $Results = Get-NAVTenant -ServerInstance $InstanceName | Sync-NAVTenant -Mode ForceSync -Force
                    UnLoad-InstanceAdminTools
                    Return $Results
                } -ArgumentList $instanceName            
            Remove-PSSession -Session $Session
        }
        $anyKey = Read-Host "Press enter to continue..."
    }    
}
