Function Stop-NAVRemoteInstance {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstances
    )
    PROCESS 
    {        
        Foreach ($selectedInstance in $SelectedInstances) {
            $instanceName = $selectedInstance.ServerInstance
            $input = Read-Host "To confirm this action please enter the Service Instance Name:"
            if ($instanceName -ieq $input) {
                Write-Host "Stopping $instanceName on $($SelectedInstance.HostName):"
                $Session = New-NAVRemoteSession -Credential $Credential -HostName $SelectedInstance.PSComputerName 
                Invoke-Command -Session $Session -ScriptBlock `
                    {
                        param([string] $InstanceName)
                        Load-InstanceAdminTools -SetupParameters $SetupParameters
                        $Results = Set-NAVServerInstance -ServerInstance $InstanceName -Stop
                        UnLoad-InstanceAdminTools
                        Return $Results
                    } -ArgumentList $instanceName 
                Remove-PSSession -Session $Session
            }
        }
    }    
}
