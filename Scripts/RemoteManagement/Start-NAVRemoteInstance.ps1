Function Start-NAVRemoteInstance {
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
            Write-Host "Starting $instanceName on $($SelectedInstance.HostName):"
            $Session = Create-NAVRemoteSession -Credential $Credential -HostName $SelectedInstance.PSComputerName 
            Invoke-Command -Session $Session -ScriptBlock `
                {
                    param([string] $InstanceName)
                    Load-InstanceAdminTools -SetupParameters $SetupParameters
                    $Results = Set-NAVServerInstance -ServerInstance $InstanceName -Start
                    UnLoad-InstanceAdminTools
                    Return $Results
                } -ArgumentList $instanceName
        }
    }    
}
