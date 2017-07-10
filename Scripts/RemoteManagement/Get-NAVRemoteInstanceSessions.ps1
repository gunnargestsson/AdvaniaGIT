Function Get-NAVRemoteInstanceSessions {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )
    PROCESS 
    {
        $Session = New-NAVRemoteSession -Credential $Credential -HostName $SelectedInstance[0].PSComputerName 
        $Sessions = Invoke-Command -Session $Session -ScriptBlock `
            {
                param([String]$ServerInstance)
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                $Sessions = Get-NAVServerSession -ServerInstance $ServerInstance
                UnLoad-InstanceAdminTools
                return $Sessions
            } -ArgumentList $SelectedInstance[0].ServerInstance
        Remove-PSSession -Session $Session
        $Sessions | Format-Table -Property ServerInstanceName, ServerComputerName, UserID, ClientType, ClientComputerName, LoginDatetime -AutoSize
        $anyKey = Read-Host "Press enter to continue..."
    }    
}