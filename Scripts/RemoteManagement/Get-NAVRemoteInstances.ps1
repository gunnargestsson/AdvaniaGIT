Function Get-NAVRemoteInstances {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyname=$true)]
        [bool]$Tenants = $true,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyname=$true)]
        [bool]$TenantCompanies = $false
    )
    PROCESS 
    {
        $Instances = Invoke-Command -Session $Session -ScriptBlock `
            {
                param([bool]$Tenants,[bool]$TenantCompanies)
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
                    if ($Tenants) {
                        if ($Instance.State -eq "Running") {
                            foreach ($Tenant in (Get-NAVTenant -ServerInstance $Instance.ServerInstance)) {
                                $TenantSettings = Get-TenantSettings -SetupParameters $SetupParameters -Tenant $Tenant
                                $TenantCompanyList = @()
                                if ($TenantCompanies) {
                                    $TenantCompanyList += (Get-NAVCompany -ServerInstance $Instance.ServerInstance -Tenant $Tenant.Id).CompanyName
                                }
                                $TenantSettings | Add-Member -MemberType NoteProperty -Name CompanyList -Value $TenantCompanyList
                                $TenantList += Combine-Settings $TenantSettings $Tenant
                            }
                        }
                    }
                    $instanceConfig | Add-Member -MemberType NoteProperty -Name TenantList -Value $TenantList
                    $InstanceConfigs += Combine-Settings $instanceConfig $instance
                }
                UnLoad-InstanceAdminTools
                Return $InstanceConfigs
            } -ArgumentList ($Tenants, $TenantCompanies) 
        Return $Instances
    }    
}