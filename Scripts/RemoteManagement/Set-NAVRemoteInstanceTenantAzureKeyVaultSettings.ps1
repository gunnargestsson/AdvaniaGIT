Function Set-NAVRemoteInstanceTenantAzureKeyVaultSettings {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$ServerInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$KeyVault,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$RemoteConfig,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$RemoteComputer
    )
    PROCESS 
    {       

        if ($ServerInstance.Multitenant -ieq "true") {
            Write-Host "Reconfiguring Tenants..."

            $DbAdmin = Get-NAVPasswordStateUser -PasswordId $RemoteConfig.DBUserPasswordID
            if ($DbAdmin.UserName -gt "" -and $DbAdmin.Password -gt "") {
                $DatabaseCredential= New-Object System.Management.Automation.PSCredential($DbAdmin.UserName, (ConvertTo-SecureString $DbAdmin.Password -AsPlainText -Force))
            } else {
                $DatabaseCredential= Get-Credential -Message "Azure SQL Access Credentials" -ErrorAction Stop    
            }

            $AzureKeyVaultSettings = New-Object -TypeName PSObject
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultClientId -Value $ServerInstance.ADApplicationApplicationId
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultClientCertificateStoreLocation -Value LocalMachine
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultClientCertificateStoreName -Value My
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultClientCertificateThumbprint -Value $ServerInstance.ServicesCertificateThumbprint
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultKeyUri -Value ""
            $TenantKeyList = Create-NAVAzureKeyVaultTenantKeys -KeyVault $KeyVault -ServerInstance $ServerInstance
            $Param = @{
                Session = $Session
                TenantList = $TenantKeyList
                AzureKeyVaultSettings = $AzureKeyVaultSettings
                DatabaseCredential = $DatabaseCredential
                RemoteComputer = $RemoteComputer
            }

            if ($ServerInstance.NASServicesRunWithAdminRights -ieq "true") {
                $Param.NasServicesEnabled = $true
            }

            if ($RemoteComputer.TenantSettings.AllowAppDatabaseWrite -ieq "true") {
                $Param.AllowAppDatabaseWrite = $true
            }
            Set-NAVRemoteInstanceTenantConfiguration @Param
            Start-NAVRemoteInstanceTenantsSync -Session $Session -SelectedInstanceName $ServerInstance.ServerInstance
        }
    }
}