Function New-NAVDeploymentRemoteInstance {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Subscription,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    { 
        $RemoteConfig = Get-NAVRemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        $IconFilePath = Get-NAVClickOnceApplicationIcon -Credential $Credential -DeploymentName $DeploymentName 
        $KeyVault = Get-NAVAzureKeyVault -DeploymentName $DeploymentName
        if (!$KeyVault) { break }

        #Ask for Instance Name 
        $SelectedInstance = New-NAVInstanceSettingsDialog -Message "Create new service instance" 
        if ($SelectedInstance.OKPressed -ne 'OK') { break }
        $ServerInstance = $SelectedInstance.ServerInstance

        $Database = New-NAVDatabaseObject 
        $DBAdmin = Get-NAVPasswordStateUser -PasswordId $RemoteConfig.DBUserPasswordID
        if ($DBAdmin.UserName -gt "") { $Database.DatabaseUserName = $DBAdmin.UserName }
        if ($DBAdmin.Password -gt "") { $Database.DatabasePassword = $DBAdmin.Password }
        if ($DBAdmin.GenericField1 -gt "") { $Database.DatabaseServerName = $DBAdmin.GenericField1 }

        #Ask Database Settings
        $Database = New-NAVDatabaseDialog -Message "Enter details on database." -Database $Database
        if ($Database.OKPressed -ne 'OK') { break }

        #Ask for Tenant Settings $SelectedTenant
        $TenantSettings = Get-NAVRemoteInstanceDefaultTenant -SelectedInstance $SelectedInstance 
        $TenantSettings.ClickOnceHost = "$($ExecutionContext.InvokeCommand.ExpandString($Remotes.ClickOnceHost))".ToLower()
        $TenantSettings = Combine-Settings $TenantSettings (New-NAVTenantSettingsObject)
        $SelectedTenant = New-NAVTenantSettingsDialog -Message "Edit Tenant Settings" -TenantSettings $TenantSettings -TenantIdNotEditable
        if ($SelectedTenant.OKPressed -ne 'OK') { break }
        if ($SelectedTenant.CustomerName -eq "") { 
            Write-Host -ForegroundColor Red "Customer Name missing!"
            break
        }
        $EncryptionAdmin = Get-NAVPasswordStateUser -PasswordId $RemoteConfig.EncryptionKeyPasswordID
        if ($EncryptionAdmin.Password -gt "") {
            $EncryptionKeyPassword = $EncryptionAdmin.Password
        } else {
            $EncryptionKeyPassword = Get-Password -Message "Enter password for the encryption key:"
        }

        if ($SelectedTenant.LicenseNo -gt "" ) {
            $FtpFileName = "license/$($SelectedTenant.LicenseNo).flf"
            $LocalFileName = Join-Path $env:TEMP "$($SelectedTenant.LicenseNo).flf"
            try { Get-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpFilePath $FtpFileName -LocalFilePath $LocalFileName }
            catch { Write-Host "Unable to download license from $LocalFileName !" }
        } 
        $hostNo = 1
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            Write-Host "Updating $($RemoteComputer.HostName)..."
            $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN         
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {

                New-NAVRemoteInstance -Session $Session -ServerInstance $SelectedInstance.ServerInstance 
                Set-NAVRemoteInstanceDatabase -Session $Session -SelectedInstance $SelectedInstance -Database $Database -EncryptionKeyPath $RemoteComputer.EncryptionKeyPath -EncryptionKeyPassword $EncryptionKeyPassword -InstanceSettings $RemoteComputer.InstanceSettings 
                $NewInstance = Get-NAVRemoteInstance -Session $Session -ServerInstanceName $SelectedInstance.ServerInstance 
                $CertValue = Get-NAVServiceCertificateValue -Session $Session -ServerInstance $NewInstance 
                $KeyVaultKey = Get-NAVAzureKeyVaultKey -KeyVault $KeyVault -ServerInstanceName $NewInstance.ServerInstance
                $Application = Get-NAVADApplication -DeploymentName $DeploymentName -ServerInstance $NewInstance -IconFilePath $IconFilePath -CertValue $CertValue
                $ServicePrincipal = Get-NAVADServicePrincipal -ADApplication $Application                   
                Set-AzureRmKeyVaultAccessPolicy -VaultName $KeyVault.VaultName -ServicePrincipalName $ServicePrincipal.ServicePrincipalNames[1] -PermissionsToKeys encrypt,decrypt,get
                Set-AzureRmKeyVaultAccessPolicy -VaultName $KeyVault.VaultName -ApplicationId $Application.ApplicationId -ObjectId $Application.ObjectId -PermissionsToKeys encrypt,decrypt,get
                $NewInstance = Combine-Settings $NewInstance $KeyVault -Prefix KeyVault
                $NewInstance = Combine-Settings $NewInstance $KeyVaultKey -Prefix KeyVaultKey
                $NewInstance = Combine-Settings $NewInstance $ServicePrincipal -Prefix ServicePrincipal
                $NewInstance = Combine-Settings $NewInstance $Application -Prefix ADApplication
                $NewInstance | Add-Member -MemberType NoteProperty -Name ADApplicationFederationMetadataLocation -Value "https://login.windows.net/$($Subscription.Account.Id.Split("@").GetValue(1))/federationmetadata/2007-06/federationmetadata.xml"
                Set-NAVRemoteInstanceADRegistration -Session $Session -ServerInstance $NewInstance 
                Start-NAVRemoteInstance -Session $Session -SelectedInstances $NewInstance
                Start-NAVRemoteInstanceSync -Session $Session -SelectedInstances $NewInstance

                if ($hostNo -eq 1) {
                    $Users = Get-NAVRemoteInstanceTenantUsers -Session $Session -SelectedTenant $SelectedTenant
                    $NAVSuperUser = $Users | Where-Object -Property UserName -EQ $RemoteConfig.NAVSuperUser
                    if (!$NAVSuperUser) {
                        $NewPassword = Get-NewUserPassword
                        New-NAVRemoteInstanceTenantUser -Session $Session -SelectedTenant $SelectedTenant -User (New-NAVUserObject -UserName $RemoteConfig.NAVSuperUser) -NewPassword $NewPassword 
                        if ($RemoteConfig.PasswordStateAPIKey -gt "") {
                            $Response = Set-NAVPasswordStateUser -Title $SelectedTenant.CustomerName -UserName $RemoteConfig.NAVSuperUser -FullName "NAV Super User" -Password $NewPassword
                            $SelectedTenant.PasswordID = $Response.PasswordID
                            $RemoteTenantSettings = Set-NAVRemoteInstanceTenantSettings -Session $Session -SelectedTenant $SelectedTenant
                        }   
                    }
                    $NAVAccountantUser = $Users | Where-Object -Property UserName -EQ $RemoteConfig.NAVAccountantUser
                    if (!$NAVAccountantUser) {
                        $NewPassword = Get-NewUserPassword
                        New-NAVRemoteInstanceTenantUser -Session $Session -SelectedTenant $SelectedTenant -User (New-NAVUserObject -UserName $RemoteConfig.NAVAccountantUser) -NewPassword $NewPassword -ChangePasswordAtNextLogOn
                    }
                    Set-NAVAzureDnsZoneRecord -DeploymentName $DeploymentName -DnsHostName $SelectedTenant.ClickOnceHost -OldDnsHostName ""
                    $hostNo ++
                }
                if ($LocalFileName) {
                    if (Test-Path $LocalFileName) {
                        $LicenseData = [Byte[]] (Get-Content -Path $LocalFileName -Encoding Byte)   
                        Set-NAVRemoteInstanceTenantLicense -Session $Session -SelectedTenant $SelectedTenant -LicenseData $LicenseData                         
                    }
                }
                $RemoteTenantSettings = Set-NAVRemoteInstanceTenantSettings -Session $Session -SelectedTenant $SelectedTenant 
                $NewInstance = Get-NAVRemoteInstances -Session $Session | Where-Object -Property ServerInstance -EQ $SelectedInstance.ServerInstance
                $SelectedInstance = Combine-Settings $NewInstance $SelectedInstance
            }
            if ($Roles -like "*ClickOnce*") {
            
                # Do some tests and import modules
                Prepare-NAVRemoteClickOnceSite -Session $Session -RemoteComputer $RemoteComputer 

                # Prepare and Clean Up      
                Remove-NAVRemoteClickOnceSite -Session $Session -SelectedTenant $SelectedTenant  

                if ($SelectedTenant.CustomerName -gt "" -and $SelectedTenant.ClickOnceHost -gt "") {
                    Write-Host "Building ClickOnce Site for $($SelectedTenant.CustomerName)..."
                    # Create the ClickOnce Site
                    New-NAVRemoteClickOnceSite -Session $Session -SelectedInstance $SelectedInstance -SelectedTenant $SelectedTenant -ClickOnceApplicationName $Remotes.ClickOnceApplicationName -ClickOnceApplicationPublisher $Remotes.ClickOnceApplicationPublisher -ClientSettings $RemoteComputer.ClientSettings
                }
            }
            if ($Roles -like "*Web*") {
            
                # Remove old Web Instance
                Remove-NAVRemoteWebInstance -Session $Session -SelectedInstance $SelectedInstance 
                                               
                # Create the Web Instance
                New-NAVRemoteWebInstance -Session $Session -SelectedInstance $SelectedInstance -ClientSettings $RemoteComputer.ClientSettings                
            }
            Remove-PSSession $Session
        }
        if (Test-Path $LocalFileName) {
            Remove-Item -Path $LocalFileName -Force -ErrorAction SilentlyContinue
        }
        Write-Host "Instance created.  "
        if (!$NAVAccountantUser) {
            Write-Host "User $($RemoteConfig.NAVAccountantUser) created with password ${NewPassword}"
        }
        $anyKey = Read-Host "Press enter to continue..."
    }    
}