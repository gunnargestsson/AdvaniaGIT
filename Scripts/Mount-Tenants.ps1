# Import all needed modules
Get-Module AdvaniaGIT | Remove-Module
Get-Module RemoteManagement | Remove-Module
Import-Module RemoteManagement -DisableNameChecking | Out-Null
Import-Module AdvaniaGIT -DisableNameChecking | Out-Null
Import-Module AzureRM
Import-Module AzureAD
   
# Get Environment Settings
$SetupParameters = Get-GITSettings
$RemoteConfig = Get-NAVRemoteConfig

$VMAdmin = Get-NAVUserPasswordObject -Usage "VMUserPasswordID"
if ($VMAdmin.UserName -gt "" -and $VMAdmin.Password -gt "") {
    $Credential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))
} else {
    $Credential = Get-Credential -Message "Remote Login to VM Hosts" -ErrorAction Stop    
}

if (!$Credential.UserName -or !$Credential.Password) {
    Write-Host -ForegroundColor Red "Credentials required!"
    break
}

$DBAdmin = Get-NAVUserPasswordObject -Usage "DBUserPasswordID"

$AzureRMAdmin = Get-NAVUserPasswordObject -Usage "AzureRMUserPasswordID"
if ($AzureRMAdmin.UserName -gt "" -and $AzureRMAdmin.Password -gt "") {
    $AzureCredential = New-Object System.Management.Automation.PSCredential($AzureRMAdmin.UserName, (ConvertTo-SecureString $AzureRMAdmin.Password -AsPlainText -Force))
} else {
    $AzureCredential = Get-Credential -Message "Remote Login to Azure Dns" -ErrorAction Stop    
}

if (!$AzureCredential.UserName -or !$AzureCredential.Password) {
    Write-Host -ForegroundColor Red "Azure Credentials required!"
    break
}

$Login = Login-AzureRmAccount -Credential $AzureCredential
$Subscription = Select-AzureRmSubscription -SubscriptionName $RemoteConfig.AzureRMSubscriptionName -ErrorAction Stop
$MsolService = Connect-MsolService -Credential $AzureCredential 
$AzureAD = Connect-AzureAD -Credential $AzureCredential 

# Manual Config Starts
$Settings = Get-Item -Path C:\NAVManagementWorkFolder\Workspace\PUB2016.json
$DeploymentName = 'TOK2016'
# Manual Config Ends

$Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName

$Session1 = New-NAVRemoteSession -Credential $Credential -HostName $Remotes.Hosts[0].FQDN
$Session2 = New-NAVRemoteSession -Credential $Credential -HostName $Remotes.Hosts[1].FQDN
$ServerInstance = Get-NAVRemoteInstances -Session $Session1 

$Tenants = Get-Content -Path $Settings.FullName -Encoding UTF8 | Out-String | ConvertFrom-Json
foreach ($Tenant in $Tenants) {
    Set-NAVAzureDnsZoneRecord -DeploymentName $DeploymentName -DnsHostName $Tenant.'Alternate Id' -OldDnsHostName ""
    Write-Host "Mounting Tenant $($Tenant.'Tenant ID')..."
    $Database = New-NAVDatabaseObject -DatabaseName "Tenant-$($Tenant.'Customer Registration No.')"
    if ($DBAdmin.UserName -gt "") { $Database.DatabaseUserName = $DBAdmin.UserName }
    if ($DBAdmin.Password -gt "") { $Database.DatabasePassword = $DBAdmin.Password }
    if ($DBAdmin.GenericField1 -gt "") { $Database.DatabaseServerName = $DBAdmin.GenericField1 }
    $TenantSettings = New-NAVTenantSettingsObject `
        -Id $Tenant.'Tenant ID' `
        -ServerInstance $ServerInstance.ServerInstance `
        -CustomerRegistrationNo $Tenant.'Customer Registration No.' `
        -CustomerName $Tenant.'Customer Name' `
        -CustomerEMail $Tenant.'Customer E-Mail' `
        -PasswordId ($Tenant.'Password Link').Split("=")[1] `
        -LicenseNo $Tenant.'License File Code' `
        -ClickOnceHost $Tenant.'Alternate Id' `
        -Language (Get-Culture).Name 

    $Param = @{
        Session = $Session1
        SelectedTenant = $TenantSettings
        Database = $Database
    }

    if ($ServerInstance.NASServicesRunWithAdminRights -ieq "true") {
        $Param.NasServicesEnabled = $true
    }

    if ($Remotes.Hosts[0].TenantSettings.AllowAppDatabaseWrite -ieq "true") {
        $Param.AllowAppDatabaseWrite = $true
    }
    Mount-NAVRemoteInstanceTenant @Param

    $RemoteTenantSettings1 = Set-NAVRemoteInstanceTenantSettings -Session $Session1 -SelectedTenant $TenantSettings
    $RemoteTenantSettings2 = Set-NAVRemoteInstanceTenantSettings -Session $Session2 -SelectedTenant $TenantSettings

}
Start-NAVRemoteInstanceSync -Session $Session1 -SelectedInstances $ServerInstance
Start-NAVRemoteInstanceSync -Session $Session2 -SelectedInstances $ServerInstance