$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Write-Host "Upgrading NAV Database $($DeploymentSettings.databaseToUpgrade)..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName,[string]$databaseToUpgrade,[string]$databaseWithUpgradeCode,[string]$databaseWithAcceptanceCode,[string]$licensePath)

    Load-InstanceAdminTools -SetupParameters $SetupParameters

    $InstanceSettings = Get-NAVServerConfiguration -ServerInstance $instanceName -AsXml
    $databaseServer = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='DatabaseServer']").Attributes["value"].Value

    Write-Host "Stopping server instance ${instanceName}..."
    Set-NAVServerInstance -ServerInstance $instanceName -Stop

    Write-Host "Remove application from database ${databaseServer}\${databaseToUpgrade}..."
    Remove-NAVApplication -DatabaseServer $databaseServer -DatabaseName $databaseToUpgrade -Force 
    Write-Host "Import application from ${databaseServer}\${databaseWithUpgradeCode}..."
    Export-NAVApplication -DatabaseServer $databaseServer -DatabaseName $databaseWithUpgradeCode -DestinationDatabaseName $databaseToUpgrade -Force
    Write-Host "Switch Serviceinstance ${instanceName} to ${databaseServer}\${databaseToUpgrade}..."
    Set-NAVServerConfiguration -ServerInstance $instanceName -KeyName DatabaseName -KeyValue $databaseToUpgrade
    Set-NAVServerInstance -ServerInstance $instanceName -Start
    Import-NAVServerLicense -ServerInstance $instanceName -LicenseFile $licensePath -Database NavDatabase
    Write-Host "Syncing database layout changes..."
    Sync-NAVTenant -ServerInstance $instanceName -Mode Sync -Force -CommitPerTable -ErrorAction Stop
    $state = (Get-NAVTenant -ServerInstance $instanceName).State
    $noOfRestarts = 0
    while ($state -ne "Operational" -and $state -ne "OperationalDataUpgradePending") {
        if ($noOfRestart -gt 3) {
            Write-Host "Unable to complete tenant sync!"
            Get-NAVTenant -ServerInstance $instanceName 
            throw
        }
        Write-Host "Retrying Sync..."
        Set-NAVServerInstance -ServerInstance $instanceName -Restart
        Sync-NAVTenant -ServerInstance $instanceName -Mode ForceSync -Force -ErrorAction Stop
        $state = (Get-NAVTenant -ServerInstance $instanceName).State
        $noOfRestarts ++
    }
    Get-NAVTenant -ServerInstance $instanceName 

    Write-Host "Executing Data Upgrade..."
    Start-NAVDataUpgrade -ServerInstance $instanceName  -Language (Get-Culture).Name -FunctionExecutionMode Parallel -SkipCompanyInitialization -SkipAppVersionCheck -Force -ContinueOnError
    Get-NAVDataUpgrade -ServerInstance $instanceName -Progress -Interval 600
    Get-NAVDataUpgrade -ServerInstance $instanceName -Detailed | Format-Table
    Stop-NAVDataUpgrade -ServerInstance $instanceName  -Force
    
    $state = (Get-NAVTenant -ServerInstance $instanceName).State
    $noOfRestarts = 0
    while ($state -ne "Operational" -and $state -ne "OperationalDataUpgradePending") {
        if ($noOfRestart -gt 3) {
            Write-Host "Unable to complete tenant sync!"
            Get-NAVTenant -ServerInstance $instanceName 
            throw
        }
        Write-Host "Retrying Sync..."
        Set-NAVServerInstance -ServerInstance $instanceName -Restart
        Sync-NAVTenant -ServerInstance $instanceName -Mode ForceSync -Force -ErrorAction Stop
        $state = (Get-NAVTenant -ServerInstance $instanceName).State
        $noOfRestarts ++
    }

    Write-Host "Stopping server instance ${instanceName}..."
    Set-NAVServerInstance -ServerInstance $instanceName -Stop
    Write-Host "Remove upgrade application from database ${databaseServer}\${databaseToUpgrade}..."
    Remove-NAVApplication -DatabaseServer $databaseServer -DatabaseName $databaseToUpgrade -Force 
    Write-Host "Import application from ${databaseServer}\${databaseWithAcceptanceCode}..."
    Export-NAVApplication -DatabaseServer $databaseServer -DatabaseName $databaseWithAcceptanceCode -DestinationDatabaseName $databaseToUpgrade -Force
    Set-NAVServerInstance -ServerInstance $instanceName -Start
    Sync-NAVTenant -ServerInstance $instanceName -Mode ForceSync -CommitPerTable -Force -ErrorAction Stop

    UnLoad-InstanceAdminTools

    } -ArgumentList ($DeploymentSettings.instanceName, $DeploymentSettings.databaseToUpgrade, $DeploymentSettings.databaseWithUpgradeCode, $DeploymentSettings.databaseWithAcceptanceCode, $DeploymentSettings.licensePath )


$Session | Remove-PSSession