Function Start-NAVDeploymentRemoteInstanceSync {
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
            Write-Host "Syncronizing Tenants for $instanceName on $($SelectedInstance.HostName):"
            $Session = New-NAVRemoteSession -Credential $Credential -HostName $SelectedInstance.PSComputerName 
            Start-NAVRemoteInstanceSync -Session $Session -SelectedInstances $selectedInstance
            Remove-PSSession -Session $Session
        }
        $anyKey = Read-Host "Press enter to continue..."
    }    
}
