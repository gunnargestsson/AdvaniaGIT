# Import all needed modules
Get-Module RemoteManagement | Remove-Module
Get-Module AdvaniaGIT | Remove-Module
Import-Module RemoteManagement -DisableNameChecking | Out-Null
Import-Module AdvaniaGIT -DisableNameChecking | Out-Null
Import-Module AzureRM

# Get Environment Settings
$SetupParameters = Get-GITSettings
$RemoteConfig = Get-NAVRemoteConfig

$DBAdmin = Get-NAVPasswordStateUser -PasswordId $RemoteConfig.DBUserPasswordID
if ($DBAdmin.UserName -gt "" -and $DBAdmin.Password -gt "") {
    $Credential = New-Object System.Management.Automation.PSCredential($DBAdmin.UserName, (ConvertTo-SecureString $DBAdmin.Password -AsPlainText -Force))
} else {
    $Credential = Get-Credential -Message "Remote Login to Azure SQL" -ErrorAction Stop
    $DBAdmin.UserName = $Credential.UserName
    $DBAdmin.Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password))
}    

if (!$Credential.UserName -or !$Credential.Password) {
    Write-Host -ForegroundColor Red "Credentials required!"
    break
}

$VMAdmin = Get-NAVPasswordStateUser -PasswordId $RemoteConfig.VMUserPasswordID
if ($VMAdmin.UserName -gt "" -and $VMAdmin.Password -gt "") {
    $VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))
} else {
    $VMCredential = Get-Credential -Message "Admin Access to Azure SQL" -ErrorAction Stop    
}

if (!$VMCredential.UserName -or !$VMCredential.Password) {
    Write-Host -ForegroundColor Red "Credentials required!"
    break
}

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

$Login = Login-AzureRmAccount -Credential $AzureCredential
$Subscription = Select-AzureRmSubscription -SubscriptionName $RemoteConfig.AzureRMSubscriptionName -ErrorAction Stop

if ($DBAdmin.GenericField1 -gt "") {
    $databaseServer = Get-AzureRmResourceGroup | Get-AzureRmSqlServer | Where-Object -Property ServerName -ieq $DBAdmin.GenericField1.Split(".").GetValue(0)
    $resourceGroup = Get-AzureRmResourceGroup -Name $databaseServer.ResourceGroupName
} else {
    Remove-Variable resourceGroup -ErrorAction SilentlyContinue
    Remove-Variable databaseServer -ErrorAction SilentlyContinue
}

#Select Azure Resource Group
if (!$resourceGroup) { $resourceGroup = Get-NAVAzureResourceGroup }
if (!$resourceGroup) {
    Write-Host -ForegroundColor Red "Azure Resource Group required!"
    break
}

# Select Azure Sql Database Server
if (!$databaseServer) { $databaseServer = Get-NAVAzureSqlServer -AzureResourceGroup $resourceGroup }
if (!$databaseServer) {
    Write-Host -ForegroundColor Red "Azure Sql Database Server required!"
    break
}

$SelectedElasticPool = Get-NAVAzureSqlElasticPool -AzureResourceGroup $resourceGroup -SqlServer $databaseServer
if (!$SelectedElasticPool) { break }

$XlsFileName = Get-Item -Path C:\NAVManagementWorkFolder\Workspace\PUB2016.xlsx
$TenantList = Read-XlsFile -XlsFilePath $XlsFileName.FullName 

$UserName = $VMCredential.UserName
$Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($VMCredential.Password))

foreach ($Tenant in $TenantList) {
    $DatabaseName = "Tenant-$($Tenant.'Customer Registration No.')"
    $databaseExists = Get-AzureRmSqlDatabase -DatabaseName $DatabaseName -ResourceGroupName $resourceGroup.ResourceGroupName -ServerName $databaseServer.ServerName -ErrorAction SilentlyContinue
    if ($databaseExists) {
        Write-Host -ForegroundColor Red "Database ${DatabaseName} already exists!"
    } else {
        Write-Host "Creating database ${DatabaseName}..."
        $Database = New-AzureRmSqlDatabase -DatabaseName $DatabaseName -CollationName Icelandic_100_CS_AS -Edition Standard -ElasticPoolName $SelectedElasticPool.ElasticPoolName -ServerName $databaseServer.ServerName -ResourceGroupName $resourceGroup.ResourceGroupName
        $Result = Get-SQLCommandResult -Server "$($databaseServer.ServerName).database.windows.net" -Database $DatabaseName -Command "CREATE USER $($Credential.UserName) FROM LOGIN $($Credential.UserName);" -Username $UserName -Password $Password
        $Result = Get-SQLCommandResult -Server "$($databaseServer.ServerName).database.windows.net" -Database $DatabaseName -Command "ALTER ROLE db_owner ADD MEMBER $($Credential.UserName);" -Username $UserName -Password $Password
    }
}