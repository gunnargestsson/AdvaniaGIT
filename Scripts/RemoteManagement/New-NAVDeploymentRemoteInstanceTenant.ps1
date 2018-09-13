Function New-NAVDeploymentRemoteInstanceTenant {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )
    PROCESS 
    { 
        $RemoteConfig = Get-NAVRemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName

        $Database = New-NAVDatabaseObject 
        $DBAdmin = Get-NAVUserPasswordObject -Usage "DBAdminPasswordID"
        if ($DBAdmin.UserName -gt "") { $Database.DatabaseUserName = $DBAdmin.UserName }
        if ($DBAdmin.Password -gt "") { $Database.DatabasePassword = $DBAdmin.Password }
        if ($DBAdmin.GenericField1 -gt "") { $Database.DatabaseServerName = $DBAdmin.GenericField1 }

        #Ask Database Settings
        $Database = New-NAVDatabaseDialog -Message "Enter details on database." -Database $Database
        if ($Database.OKPressed -ne 'OK') { break }

        #Ask for Tenant Settings $SelectedTenant
        $TenantSettings = New-NAVTenantSettingsObject -Id New_Tenant -ServerInstance $SelectedInstance.ServerInstance -Language (Get-Culture).Name 
        $TenantSettings = Combine-Settings $TenantSettings (New-NAVTenantSettingsObject)
        $SelectedTenant = New-NAVTenantSettingsDialog -Message "Edit New Tenant Settings" -TenantSettings $TenantSettings
        if ($SelectedTenant.OKPressed -ne 'OK') { break }

        if ($SelectedTenant.ClickOnceHost) {
            Set-NAVAzureDnsZoneRecord -DeploymentName $DeploymentName -DnsHostName $SelectedTenant.ClickOnceHost -OldDnsHostName ""
        }
        if ($SelectedTenant.CustomerName -eq "") {
            Write-Host -ForegroundColor Red "Customer Name not configured.  Configure with Tenant Settings."
            break
        } elseif ($SelectedTenant.ClickOnceHost -eq "") {
            Write-Host -ForegroundColor Red "ClickOnce Host not configured.  Configure with Tenant Settings."
            break
        } elseif (!(Resolve-DnsName -Name $SelectedTenant.ClickOnceHost -ErrorAction SilentlyContinue)) {
            Write-Host -ForegroundColor Red "Host $($SelectedTenant.ClickOnceHost) not found in Dns!"
            break
        }

        if ($SelectedTenant.LicenseNo -gt "" ) {
            $FtpFileName = "license/$($SelectedTenant.LicenseNo).flf"
            $LocalFileName = Join-Path $env:TEMP "$($SelectedTenant.LicenseNo).flf"
            try { Get-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpFilePath $FtpFileName -LocalFilePath $LocalFileName }
            catch { Write-Host "Unable to download license from $LocalFileName !" }
        } 

        if ($SelectedInstance.EncryptionProvider -eq "AzureKeyVault") {
            Write-Host "Creating Encryption key for tenant..."
            $KeyVault = Get-NAVAzureKeyVault -DeploymentName $DeploymentName
            $TenantKeyVaultKey = Get-NAVAzureKeyVaultKey -KeyVault $KeyVault -ServerInstanceName $SelectedTenant.ServerInstance -TenantId $SelectedTenant.Id
            $AzureKeyVaultSettings = New-Object -TypeName PSObject
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultClientId -Value $SelectedInstance.AzureKeyVaultClientId
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultClientCertificateStoreLocation -Value $SelectedInstance.AzureKeyVaultClientCertificateStoreLocation
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultClientCertificateStoreName -Value $SelectedInstance.AzureKeyVaultClientCertificateStoreName
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultClientCertificateThumbprint -Value $SelectedInstance.AzureKeyVaultClientCertificateThumbprint
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultKeyUri -Value $TenantKeyVaultKey.Id
        }

        $hostNo = 1
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            Write-Host "Updating $($RemoteComputer.HostName)..."
            $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN         
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {                
                if ($hostNo -eq 1) {
                    $Param = @{
                        Session = $Session
                        SelectedTenant = $SelectedTenant
                        Database = $Database
                        AzureKeyVaultSettings = $AzureKeyVaultSettings
                    }

                    if ($SelectedInstance.NASServicesRunWithAdminRights -ieq "true") {
                        $Param.NasServicesEnabled = $true
                    }

                    if ($RemoteComputer.TenantSettings.AllowAppDatabaseWrite -ieq "true" -or $SelectedTenant.Id -ieq "setup") {
                        $Param.AllowAppDatabaseWrite = $true
                    }
                    Update-NAVRemoteInstanceTenant -Session $Session -SelectedTenant $SelectedTenant -Database $Database 
                    Mount-NAVRemoteInstanceTenant @Param
                    Start-NAVRemoteInstanceTenantSync -Session $Session -SelectedTenant $SelectedTenant                    
                    $hostNo ++
                }
                $RemoteTenantSettings = Set-NAVRemoteInstanceTenantSettings -Session $Session -SelectedTenant $SelectedTenant 
            }
            if ($Roles -like "*ClickOnce*") {
                # Prepare and Clean Up      
                Remove-NAVRemoteClickOnceSite -Session $Session -SelectedTenant $SelectedTenant  

                # Do some tests and import modules
                Prepare-NAVRemoteClickOnceSite -Session $Session -RemoteComputer $RemoteComputer 

                # Create the ClickOnce Site
                New-NAVRemoteClickOnceSite -Session $Session -SelectedInstance $SelectedInstance -SelectedTenant $SelectedTenant -ClickOnceApplicationName $Remotes.ClickOnceApplicationName -ClickOnceApplicationPublisher $Remotes.ClickOnceApplicationPublisher -ClientSettings $RemoteComputer.ClientSettings
            }
            Remove-PSSession $Session
        }
        $anyKey = Read-Host "Press enter to continue..."
    }    
}