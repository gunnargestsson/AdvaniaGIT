Function Stop-NAVDeploymentRemoteInstance {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstances,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$Force
    )
    PROCESS 
    {        
        Foreach ($selectedInstance in $SelectedInstances) {
            $instanceName = $selectedInstance.ServerInstance
            if (!$Force) { $input = Read-Host "To confirm this action please enter the Service Instance Name" }
            if ($instanceName -ieq $input -or $Force) {
                Write-Host "Stopping $instanceName on $($SelectedInstance.PSComputerName)..."
                $Session = New-NAVRemoteSession -Credential $Credential -HostName $SelectedInstance.PSComputerName 
                Stop-NAVRemoteInstance -Session $Session -SelectedInstances $selectedInstance
                Remove-PSSession -Session $Session
            }
        }
    }    
}
