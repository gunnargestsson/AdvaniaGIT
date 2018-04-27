$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Write-Host "Upgrading NAV Database $($DeploymentSettings.databaseToUpgrade)..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName,[string]$upgradeInstanceName,[string]$databaseToUpgrade,[string]$databaseWithUpgradeCode,[string]$databaseWithAcceptanceCode)

    Load-InstanceAdminTools -SetupParameters $SetupParameters

    $InstanceSettings = Get-NAVServerConfiguration -ServerInstance $upgradeInstanceName -AsXml
    $databaseServer = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='DatabaseServer']").Attributes["value"].Value

    Write-Host "Stopping server instance ${instanceName}..."
    Set-NAVServerInstance -ServerInstance $instanceName -Stop

    Write-Host "Remove application from database ${databaseServer}\${databaseToUpgrade}..."
    Remove-NAVApplication -DatabaseServer $databaseServer -DatabaseName $databaseToUpgrade -Force 
    Write-Host "Import application from ${databaseServer}\${databaseWithUpgradeCode}..."
    Export-NAVApplication -DatabaseServer $databaseServer -DatabaseName $databaseWithUpgradeCode -DestinationDatabaseName $databaseToUpgrade -Force
    Write-Host "Switch Serviceinstance ${upgradeInstanceName} to ${databaseServer}\${databaseToUpgrade}..."
    Set-NAVServerInstance -ServerInstance $upgradeInstanceName -Stop
    Set-NAVServerConfiguration -ServerInstance $upgradeInstanceName -KeyName DatabaseName -KeyValue $databaseToUpgrade
    Set-NAVServerInstance -ServerInstance $upgradeInstanceName -Start
    Import-NAVServerLicense -ServerInstance $upgradeInstanceName -LicenseFile $licensePath -Database NavDatabase
    Write-Host "Syncing database layout changes..."
    Sync-NAVTenant -ServerInstance $upgradeInstanceName -Mode Sync -Force -CommitPerTable -ErrorAction Stop
    Get-NAVTenant -ServerInstance $upgradeInstanceName 
    Write-Host "Executing Data Upgrade..."
    Start-NAVDataUpgrade -ServerInstance $upgradeInstanceName  -Language (Get-Culture).Name -FunctionExecutionMode Parallel -SkipCompanyInitialization -SkipAppVersionCheck -Force -ContinueOnError
    Get-NAVDataUpgrade -ServerInstance $upgradeInstanceName -Progress -Interval 600
    Get-NAVDataUpgrade -ServerInstance $upgradeInstanceName -Detailed | Format-Table
    Write-Host "Switch Serviceinstance ${upgradeInstanceName} to ${databaseServer}\${databaseWithUpgradeCode}..."
    Set-NAVServerInstance -ServerInstance $upgradeInstanceName -Stop
    Set-NAVServerConfiguration -ServerInstance $upgradeInstanceName -KeyName DatabaseName -KeyValue $databaseWithUpgradeCode
    Set-NAVServerInstance -ServerInstance $upgradeInstanceName -Start

    Write-Host "Remove upgrade application from database ${databaseServer}\${databaseToUpgrade}..."
    Remove-NAVApplication -DatabaseServer $databaseServer -DatabaseName $databaseToUpgrade -Force 
    Write-Host "Import application from ${databaseServer}\${databaseWithAcceptanceCode}..."
    Export-NAVApplication -DatabaseServer $databaseServer -DatabaseName $databaseWithAcceptanceCode -DestinationDatabaseName $databaseToUpgrade -Force
    Write-Host "Switch Serviceinstance ${instanceName} to ${databaseServer}\${databaseToUpgrade}..."    
    Set-NAVServerConfiguration -ServerInstance $instanceName -KeyName DatabaseName -KeyValue $databaseToUpgrade
    Set-NAVServerInstance -ServerInstance $instanceName -Start
    Sync-NAVTenant -ServerInstance $instanceName -Mode ForceSync -Force -ErrorAction Stop


    UnLoad-InstanceAdminTools

    } -ArgumentList ($DeploymentSettings.instanceName, $DeploymentSettings.upgradeInstanceName, $DeploymentSettings.databaseToUpgrade, $DeploymentSettings.databaseWithUpgradeCode, $DeploymentSettings.databaseWithAcceptanceCode )


$Session | Remove-PSSession