Function Start-NAVDeploymentRemoteInstance {
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
            Write-Host "Starting $instanceName on $($SelectedInstance.PSComputerName)..."
            $Session = New-NAVRemoteSession -Credential $Credential -HostName $SelectedInstance.PSComputerName 
            Start-NAVRemoteInstance -Session $Session -SelectedInstances $SelectedInstances 
            Remove-PSSession -Session $Session
        }
    }    
}
