Function Set-NAVRemoteInstanceADRegistration {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$ServerInstance,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$RestartServerInstance
    )
    PROCESS 
    {
        Invoke-Command -Session $Session -ScriptBlock `
            {
                param([PSObject]$ServerInstance,[Bool]$RestartServerInstance)
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                if ($RestartServerInstance) {
                    Write-Host "Stopping Instance $($ServerInstance.ServerInstance)..."
                    Set-NAVServerInstance -ServerInstance $ServerInstance.ServerInstance -Stop
                }
                Write-Host "Updating Settings ..."
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName AppIdUri -KeyValue ($ServerInstance.ADApplicationIdentifierUris | Select-Object -First 1)
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName ClientServicesFederationMetadataLocation -KeyValue $ServerInstance.ADApplicationFederationMetadataLocation
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName EncryptionProvider -KeyValue AzureKeyVault
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName AzureKeyVaultClientId -KeyValue $ServerInstance.ADApplicationApplicationId
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName AzureKeyVaultClientCertificateStoreLocation -KeyValue LocalMachine
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName AzureKeyVaultClientCertificateStoreName -KeyValue My
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName AzureKeyVaultClientCertificateThumbprint -KeyValue $ServerInstance.ServicesCertificateThumbprint
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName AzureKeyVaultKeyUri -KeyValue $ServerInstance.KeyVaultKeyId

                if ($RestartServerInstance) {
                    Write-Host "Starting Instance $($ServerInstance.ServerInstance) ..."
                    Set-NAVServerInstance -ServerInstance $ServerInstance.ServerInstance -Start
                    Get-NAVTenant -ServerInstance $ServerInstance.ServerInstance | Sync-NAVTenant -Mode Sync -Force
                }
                UnLoad-InstanceAdminTools
            } -ArgumentList ($ServerInstance,$RestartServerInstance.IsPresent)
    }
}