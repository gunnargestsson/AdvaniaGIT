Function Set-NAVRemoteInstanceTenantLicense {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [Byte[]]$LicenseData
    )
    PROCESS 
    {
        Invoke-Command -Session $Session -ScriptBlock `
            {
                param([PSObject]$Tenant, [byte[]]$LicenseData) 
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                $MultiTenant = (Get-NAVServerConfiguration -ServerInstance $Tenant.ServerInstance -AsXml).DocumentElement.appSettings.SelectSingleNode("add[@key='Multitenant']").Attributes["value"].Value
                if ($MultiTenant -ieq "true") {
                    Write-Host "Updating application license for $($Tenant.ServerInstance)..."
                    Import-NAVServerLicense $Tenant.ServerInstance -LicenseData $LicenseData -Database 'NavDatabase'
                } else {
                    Write-Host "Updating license for $($Tenant.ServerInstance)/$($Tenant.Id)..."
                    if ($Tenant.Id -ieq "default") {
                        Import-NAVServerLicense $Tenant.ServerInstance -Tenant $Tenant.Id -LicenseData $LicenseData -Database 'NavDatabase'
                    } else {
                        Import-NAVServerLicense $Tenant.ServerInstance -Tenant $Tenant.Id -LicenseData $LicenseData -Database 'Tenant'
                    }
                }
                UnLoad-InstanceAdminTools
            } -ArgumentList ($SelectedTenant, $LicenseData)
    }
}