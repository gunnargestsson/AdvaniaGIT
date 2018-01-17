Function Create-NAVKontoTenant {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Accountant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$TenantConfig
    )
    
    $KontoConfig = Get-NAVKontoConfig
    $RemoteConfig = Get-NAVRemoteConfig
    $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $Provider.Deployment   

    $AzureRMAdmin = Get-NAVPasswordStateUser -PasswordId $RemoteConfig.AzureRMUserPasswordID
    if ($AzureRMAdmin.UserName -gt "" -and $AzureRMAdmin.Password -gt "") {
        $AzureCredential = New-Object System.Management.Automation.PSCredential($AzureRMAdmin.UserName, (ConvertTo-SecureString $AzureRMAdmin.Password -AsPlainText -Force))
    } else {
        $AzureCredential = Get-Credential -Message "Remote Login to Azure Dns" -ErrorAction Stop    
    }

    if (!$AzureCredential.UserName -or !$AzureCredential.Password) {
        Write-Host -ForegroundColor Red "Azure Credentials required!"
        break
    }

    if ($TenantConfig.State -eq "Not Configured") {

        $Login = Login-AzureRmAccount -Credential $AzureCredential
        $Subscription = Select-AzureRmSubscription -SubscriptionName $RemoteConfig.AzureRMSubscriptionName -ErrorAction Stop

        $clickOnceUrl = $Provider.ClickOnceUrl.Replace('<tenant>',$TenantConfig.registration_no)
        $TenantSettings = New-NAVTenantSettingsObject -Id $TenantConfig.registration_no -ServerInstance $Accountant.Instance -Language (Get-Culture).Name -CustomerRegistrationNo $TenantConfig.registration_no -CustomerName $TenantConfig.name -CustomerEMail $TenantConfig.email -ClickOnceHost $clickOnceUrl 
        Set-NAVAzureDnsZoneRecord -DeploymentName $Provider.Deployment -DnsHostName $clickOnceUrl -OldDnsHostName ""
        if (!(Resolve-DnsName -Name $clickOnceUrl -ErrorAction SilentlyContinue)) {
            Write-Host -ForegroundColor Red "Host $($clickOnceUrl) not found in Dns!"
            break
        }

        $Session = Get-NAVKontoRemoteSession -Provider $Provider
        $SelectedInstance = Get-NAVRemoteInstance -Session $Session -ServerInstanceName $Accountant.Instance
        if ($SelectedInstance.EncryptionProvider -eq "AzureKeyVault") {
            Write-Host "Creating Encryption key for tenant..."
            $KeyVault = Get-NAVAzureKeyVault -DeploymentName $Provider.Deployment
            $TenantKeyVaultKey = Get-NAVAzureKeyVaultKey -KeyVault $KeyVault -ServerInstanceName $Accountant.Instance -TenantId $TenantConfig.registration_no
            $AzureKeyVaultSettings = New-Object -TypeName PSObject
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultClientId -Value $SelectedInstance.AzureKeyVaultClientId
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultClientCertificateStoreLocation -Value $SelectedInstance.AzureKeyVaultClientCertificateStoreLocation
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultClientCertificateStoreName -Value $SelectedInstance.AzureKeyVaultClientCertificateStoreName
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultClientCertificateThumbprint -Value $SelectedInstance.AzureKeyVaultClientCertificateThumbprint
            $AzureKeyVaultSettings | Add-Member -MemberType NoteProperty -Name AzureKeyVaultKeyUri -Value $TenantKeyVaultKey.Id
        }
         
        $Database = New-NAVKontoTenantSqlDatabase -Provider $Provider -DatabaseName ("Tenant-$($TenantConfig.registration_no)")
        if ($Database -eq $null) {
          return
        }
        Update-NAVRemoteInstanceTenant -Session $Session -SelectedTenant $TenantSettings -Database $Database 
        Mount-NAVRemoteInstanceTenant -Session $Session -SelectedTenant $TenantSettings -Database $Database -AzureKeyVaultSettings $AzureKeyVaultSettings -AllowAppDatabaseWrite $true -NasServicesEnabled $true 
        Start-NAVRemoteInstanceTenantSync -Session $Session -SelectedTenant $TenantSettings
        Set-NAVDeploymentRemoteInstanceTenantSettings -Session $Session -Credential (Get-NAVKontoRemoteCredentials) -SelectedTenant $TenantSettings -DeploymentName $Provider.Deployment | Out-Null
        Remove-PSSession $Session
    } else {
        $Session = Get-NAVKontoRemoteSession -Provider $Provider
        $SelectedInstance = Get-NAVRemoteInstance -Session $Session -ServerInstanceName $Accountant.Instance
        $clickOnceUrl = $Provider.ClickOnceUrl.Replace('<tenant>',$TenantConfig.registration_no)
        $TenantSettings = Get-NAVRemoteInstanceTenantSettings -Session $Session -SelectedTenant $TenantConfig 
        $TenantSettings.ClickOnceHost = $clickOnceUrl
        $TenantSettings.CustomerRegistrationNo = $TenantConfig.registration_no 
        $TenantSettings.CustomerName = $TenantConfig.name 
        $TenantSettings.CustomerEMail = $TenantConfig.email 
        Set-NAVDeploymentRemoteInstanceTenantSettings -Session $Session -Credential (Get-NAVKontoRemoteCredentials) -SelectedTenant $TenantSettings -DeploymentName $Provider.Deployment | Out-Null
        Remove-PSSession $Session        
    }
    $TenantConfig = Combine-Settings $TenantSettings $TenantConfig
    $hostNo = 1
    Foreach ($RemoteComputer in $Remotes.Hosts) {
        Write-Host "Updating $($RemoteComputer.HostName)..."
        $Session = New-NAVRemoteSession -Credential (Get-NAVKontoRemoteCredentials) -HostName $RemoteComputer.FQDN         
        $Roles = $RemoteComputer.Roles
        if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {                
            $RemoteTenantSettings = Set-NAVRemoteInstanceTenantSettings -Session $Session -SelectedTenant $TenantConfig
        }
        if ($Roles -like "*ClickOnce*") {
            # Prepare and Clean Up      
            Remove-NAVRemoteClickOnceSite -Session $Session -SelectedTenant $TenantConfig

            # Do some tests and import modules
            Prepare-NAVRemoteClickOnceSite -Session $Session -RemoteComputer $RemoteComputer 

            # Create the ClickOnce Site
            New-NAVRemoteClickOnceSite -Session $Session -SelectedInstance $SelectedInstance -SelectedTenant $TenantConfig -ClickOnceApplicationName $Remotes.ClickOnceApplicationName -ClickOnceApplicationPublisher $Remotes.ClickOnceApplicationPublisher -ClientSettings $RemoteComputer.ClientSettings
        }
    }    
}