Function Mount-NAVRemoteInstanceTenant {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Database,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$AzureKeyVaultSettings,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Boolean]$AllowAppDatabaseWrite = $false,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Boolean]$NasServicesEnabled = $false
    )
    PROCESS 
    {
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param(                    
                    [PSObject]$SelectedTenant,
                    [PSObject]$Database,
                    [PSObject]$AzureKeyVaultSettings,
                    [Boolean]$AllowAppDatabaseWrite,
                    [Boolean]$NasServicesEnabled

                    )
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters

                $DatabaseCredentials = New-Object System.Management.Automation.PSCredential($Database.DatabaseUserName, (ConvertTo-SecureString $Database.DatabasePassword -AsPlainText -Force))
                Write-Host "Mounting $($Database.DatabaseName)..."
                $Param = @{
                    ServerInstance = $SelectedTenant.ServerInstance
                    Id = $SelectedTenant.Id
                    DatabaseName = $Database.DatabaseName
                    DatabaseServer = $Database.DatabaseServerName
                    DatabaseCredentials = $DatabaseCredentials
                    AlternateId = @($SelectedTenant.ClickOnceHost)
                    OverwriteTenantIdInDatabase = $true
                    Force = $true
                }

                if ($AzureKeyVaultSettings) {
                    $Param.EncryptionProvider = "AzureKeyVault"
                    $Param.AzureKeyVaultSettings = (New-Object Microsoft.Dynamics.Nav.Types.AzureKeyVaultSettings($AzureKeyVaultSettings.AzureKeyVaultClientId,$AzureKeyVaultSettings.AzureKeyVaultClientCertificateStoreLocation,$AzureKeyVaultSettings.AzureKeyVaultClientCertificateStoreName,$AzureKeyVaultSettings.AzureKeyVaultClientCertificateThumbprint,$AzureKeyVaultSettings.AzureKeyVaultKeyUri))
                    if ($AzureKeyVaultSettings.MajorVersion -ge 14) {
                        $Param.AadTenantId = $AzureKeyVaultSettings.AadTenantId
                        $Param.EnvironmentType = $AzureKeyVaultSettings.EnvironmentType
                    }
                }
                if ($AllowAppDatabaseWrite -or $Param.Id -ieq "setup") {
                    $Param.AllowAppDatabaseWrite = $true
                }
                if ($NasServicesEnabled) {
                    $Param.NasServicesEnabled = $true
                    $Param.RunNasWithAdminRights = $true
                }
                Mount-NAVTenant @Param
                Sync-NAVTenant -ServerInstance $SelectedTenant.ServerInstance -Tenant $SelectedTenant.Id -Mode Sync -Force

                UnLoad-InstanceAdminTools
            } -ArgumentList (
                $SelectedTenant, 
                $Database,
                $AzureKeyVaultSettings,
                $AllowAppDatabaseWrite,
                $NasServicesEnabled)
    }    
}