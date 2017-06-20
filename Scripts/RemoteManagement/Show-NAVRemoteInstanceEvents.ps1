Function Show-NAVRemoteInstanceEvents {
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
            Write-Host "Event Log from $($SelectedInstance.HostName):"
            $Session = Create-NAVRemoteSession -Credential $Credential -HostName $SelectedInstance.PSComputerName 
            Invoke-Command -Session $Session -ScriptBlock `
                {
                    param([string] $InstanceName)
                    $eventLogEntries = Show-InstanceEvents -InstanceName $InstanceName
                    Return $eventLogEntries
                } -ArgumentList $instanceName
            $anyKey = Read-Host "Press enter to continue..."
        }
    }    
}
