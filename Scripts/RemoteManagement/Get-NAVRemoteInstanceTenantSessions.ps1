Function Get-NAVRemoteInstanceTenantSessions {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
    PROCESS 
    {
        $Session = New-NAVRemoteSession -Credential $Credential -HostName $SelectedInstance.PSComputerName
        if ($SelectedTenant) { 
            $TenantId = $SelectedTenant.Id 
        } else {
            $TenantId = 'default'
        }

        Invoke-Command -Session $Session -ScriptBlock `
            {
                param([String]$ServerInstance, [String]$TenantId)
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                Get-NAVServerSession -ServerInstance $ServerInstance -Tenant $TenantId
                UnLoad-InstanceAdminTools
            } -ArgumentList ($SelectedInstance.ServerInstance, $TenantId)
        Remove-PSSession $Session
    }    
}