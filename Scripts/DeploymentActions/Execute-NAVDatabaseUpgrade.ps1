$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Write-Host "Upgrading NAV Database $($DeploymentSettings.databaseToUpgrade)..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName,[string]$databaseToUpgrade)
    $databaseServer = "localhost"

    Load-InstanceAdminTools -SetupParameters $SetupParameters

    $Tenant = Get-NAVTenant -ServerInstance $instanceName | Where-Object -Property Id -EQ default
    if ($Tenant) {
        Write-Host "Dismounting tenant default..."
        Dismount-NAVTenant -ServerInstance $instanceName -Tenant default -Force
    }

    Write-Host "Remove application from database ${databaseServer}\${databaseToUpgrade}..."
    Remove-NAVApplication -DatabaseServer $databaseServer -DatabaseName $databaseToUpgrade -Force 

    Write-Host "Mounting database ${databaseServer}\${databaseToUpgrade} on ${instanceName}..."
    Mount-NAVTenant -ServerInstance $instanceName -Tenant default -DatabaseName $databaseToUpgrade -DatabaseServer $databaseServer -AllowAppDatabaseWrite
    $Tenant = Get-NAVTenant -ServerInstance $instanceName | Where-Object -Property Id -EQ default
    if (!($Tenant)) { Throw }

    Write-Host "Syncing database layout changes..."
    Sync-NAVTenant -ServerInstance $instanceName -Tenant default -Mode Sync -Force -CommitPerTable -ErrorAction Stop
    $state = (Get-NAVTenant -ServerInstance $instanceName -Tenant default).State
    Get-NAVTenant -ServerInstance $instanceName 

    if ($state -eq "OperationalDataUpgradePending") {
        Write-Host "Executing Data Upgrade..."        
        Start-NAVDataUpgrade -ServerInstance $instanceName -Tenant default -Language (Get-Culture).Name -FunctionExecutionMode Parallel -SkipCompanyInitialization -SkipAppVersionCheck -Force -ContinueOnError
        Get-NAVDataUpgrade -ServerInstance $instanceName -Tenant default -Progress -Interval 10        
        Get-NAVDataUpgrade -ServerInstance $instanceName -Tenant default -Detailed | Format-Table -Property CodeunitId, FunctionName, CompanyName, State, Error
        foreach ($executionError in (Get-NAVDataUpgrade -ServerInstance $instanceName -Tenant default -Detailed | Where-Object -Property Error -GT "")) {
            Write-Host "Error in $($executionError.CodeunitId), function $($executionError.FunctionName):"
            Write-Host $executionError.Error | Format-List
        }        
    } else {
        Write-Host "Sync failed.  Aborting!"
        Throw
    }

    $state = (Get-NAVTenant -ServerInstance $instanceName -Tenant default).State
    Get-NAVTenant -ServerInstance $instanceName 

    if ($state -eq "Operational") {
        Write-Host "Dismounting ${databaseToUpgrade}..."
        Dismount-NAVTenant -ServerInstance $instanceName -Tenant default -Force
    } else {
        Write-Host "Data upgrade failed. Aborting!"
        Throw
    }

    UnLoad-InstanceAdminTools

    } -ArgumentList ($DeploymentSettings.instanceName, $DeploymentSettings.databaseToUpgrade)


$Session | Remove-PSSession