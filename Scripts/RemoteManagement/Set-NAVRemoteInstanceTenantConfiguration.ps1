Function Set-NAVRemoteInstanceTenantConfiguration
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$TenantList,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$AzureKeyVaultSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$DatabaseCredential
    )
    PROCESS 
    {
        $Result = Invoke-Command -Session $Session -ScriptBlock `
        {
            Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
            Load-InstanceAdminTools -SetupParameters $SetupParameters
            Add-Type -Path (Join-Path $SetupParameters.navServicePath 'Microsoft.Dynamics.Nav.Types.dll')
        }

        foreach ($tenant in $TenantList) {
            $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param([PSObject]$SelectedTenant)
                Write-Verbose "Dismounting tenant $($SelectedTenant.Id)..."
                Dismount-NAVTenant -ServerInstance $SelectedTenant.ServerInstance -Tenant $SelectedTenant.Id -Force
            } -ArgumentList $tenant
            $AzureKeyVaultSettings.AzureKeyVaultKeyUri = $tenant.Key.kid

            $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param(                    
                    [PSObject]$SelectedTenant,
                    [PSObject]$AzureKeyVaultSettings,
                    [System.Management.Automation.PSCredential]$DatabaseCredentials
                    )

                Mount-NAVTenant `
                    -ServerInstance $SelectedTenant.ServerInstance `
                    -Id $SelectedTenant.Id `
                    -DatabaseName $SelectedTenant.DatabaseName `
                    -DatabaseServer $SelectedTenant.DatabaseServerName `
                    -AllowAppDatabaseWrite `
                    -AlternateId @($SelectedTenant.ClickOnceHost) `
                    -NasServicesEnabled `
                    -RunNasWithAdminRights `
                    -DatabaseCredentials $DatabaseCredentials `
                    -EncryptionProvider AzureKeyVault `
                    -AzureKeyVaultSettings (New-Object Microsoft.Dynamics.Nav.Types.AzureKeyVaultSettings($AzureKeyVaultSettings.AzureKeyVaultClientId,$AzureKeyVaultSettings.AzureKeyVaultClientCertificateStoreLocation,$AzureKeyVaultSettings.AzureKeyVaultClientCertificateStoreName,$AzureKeyVaultSettings.AzureKeyVaultClientCertificateThumbprint,$AzureKeyVaultSettings.AzureKeyVaultKeyUri))

            } -ArgumentList (
                $tenant, 
                $AzureKeyVaultSettings,
                $DatabaseCredential)
        }

        $Result = Invoke-Command -Session $Session -ScriptBlock `
        {            
            UnLoad-InstanceAdminTools
        }
    }    
}