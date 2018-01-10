Function Set-NAVRemoteInstanceTenantLicense {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [Byte[]]$LicenseData,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$ApplicationLicense
    )
    PROCESS 
    {
        Invoke-Command -Session $Session -ScriptBlock `
            {
                param([PSObject]$Tenant, [byte[]]$LicenseData, [Boolean]$ApplicationLicense) 
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                $MultiTenant = (Get-NAVServerConfiguration -ServerInstance $Tenant.ServerInstance -AsXml).DocumentElement.appSettings.SelectSingleNode("add[@key='Multitenant']").Attributes["value"].Value
                if ($ApplicationLicense) {
                    Write-Host "Updating application license for $($Tenant.ServerInstance)..."
                    Write-Host "Updating Application database..."
                    Import-NAVServerLicense $Tenant.ServerInstance -LicenseData $LicenseData -Database 'NavDatabase'
                } else {
                    Write-Host "Updating license for $($Tenant.ServerInstance)/$($Tenant.Id)..."
                    if ($MultiTenant -ieq "true") {
                        Write-Host "Updating Tenant database..."
                        Import-NAVServerLicense $Tenant.ServerInstance -Tenant $Tenant.Id -LicenseData $LicenseData -Database 'Tenant'
                    } else {
                        Write-Host "Updating Application database..."
                        Import-NAVServerLicense $Tenant.ServerInstance -Tenant $Tenant.Id -LicenseData $LicenseData -Database 'NavDatabase'                        
                    }
                }
                UnLoad-InstanceAdminTools
            } -ArgumentList ($SelectedTenant, $LicenseData, $ApplicationLicense.IsPresent)
    }
}