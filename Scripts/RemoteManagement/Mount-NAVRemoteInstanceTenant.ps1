Function Mount-NAVRemoteInstanceTenant {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Database,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$AzureKeyVaultSettings 
    )
    PROCESS 
    {
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param(                    
                    [PSObject]$SelectedTenant,
                    [PSObject]$Database,
                    [PSObject]$AzureKeyVaultSettings 
                    )
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters

                $DatabaseCredentials = New-Object System.Management.Automation.PSCredential($Database.DatabaseUserName, (ConvertTo-SecureString $Database.DatabasePassword -AsPlainText -Force))

                if ($AzureKeyVaultSettings) {
                    Mount-NAVTenant `
                        -ServerInstance $SelectedTenant.ServerInstance `
                        -Id $SelectedTenant.Id `
                        -DatabaseName $Database.DatabaseName `
                        -DatabaseServer $Database.DatabaseServerName `
                        -AllowAppDatabaseWrite `
                        -AlternateId @($SelectedTenant.ClickOnceHost) `
                        -NasServicesEnabled `
                        -RunNasWithAdminRights `
                        -DatabaseCredentials $DatabaseCredentials `
                        -EncryptionProvider AzureKeyVault `
                        -AzureKeyVaultSettings (New-Object Microsoft.Dynamics.Nav.Types.AzureKeyVaultSettings($AzureKeyVaultSettings.AzureKeyVaultClientId,$AzureKeyVaultSettings.AzureKeyVaultClientCertificateStoreLocation,$AzureKeyVaultSettings.AzureKeyVaultClientCertificateStoreName,$AzureKeyVaultSettings.AzureKeyVaultClientCertificateThumbprint,$AzureKeyVaultSettings.AzureKeyVaultKeyUri))
                } else {
                    Mount-NAVTenant `
                        -ServerInstance $SelectedTenant.ServerInstance `
                        -Id $SelectedTenant.Id `
                        -DatabaseName $Database.DatabaseName `
                        -DatabaseServer $Database.DatabaseServerName `
                        -AllowAppDatabaseWrite `
                        -AlternateId @($SelectedTenant.ClickOnceHost) `
                        -NasServicesEnabled `
                        -RunNasWithAdminRights `
                        -DatabaseCredentials $DatabaseCredentials
                }

                UnLoad-InstanceAdminTools
            } -ArgumentList (
                $SelectedTenant, 
                $Database,
                $AzureKeyVaultSettings)
    }    
}