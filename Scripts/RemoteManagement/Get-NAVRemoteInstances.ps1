Function Get-NAVRemoteInstances {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )
    PROCESS 
    {
        $Instances = Invoke-Command -Session $Session -ScriptBlock `
            {
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                $InstanceConfigs = @()
                $Instances = Get-NAVServerInstance
                foreach ($Instance in $Instances) {
                    $config = Get-NAVServerConfiguration -ServerInstance $Instance.ServerInstance -AsXml
                    $Childs = $config.DocumentElement.appSettings.ChildNodes
                    $instanceConfig = New-Object -TypeName PSObject
                    foreach ($Child in $Childs) { 
                        $instanceConfig | Add-Member -MemberType NoteProperty -Name $($Child.Attributes["key"].Value) -Value $($Child.Attributes["value"].Value)
                    }
                    $TenantList = @()
                    if ($Instance.State -eq "Running") {
                        foreach ($Tenant in (Get-NAVTenant -ServerInstance $Instance.ServerInstance)) {
                            $TenantSettings = Get-TenantSettings -SetupParameters $SetupParameters -Tenant $Tenant
                            $TenantList += Combine-Settings $TenantSettings $Tenant 
                        }
                    }
                    $instanceConfig | Add-Member -MemberType NoteProperty -Name TenantList -Value $TenantList
                    $InstanceConfigs += Combine-Settings $instanceConfig $instance
                }
                UnLoad-InstanceAdminTools
                Return $InstanceConfigs
            } 
        Return $Instances
    }    
}