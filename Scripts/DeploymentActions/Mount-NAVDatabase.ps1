$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Write-Host "Mounting NAV Database $($DeploymentSettings.databaseToMount)..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName,[string]$tenantId,[string]$databaseToMount)

    Load-InstanceAdminTools -SetupParameters $SetupParameters

    Write-Host "Mounting database as default tenant ${databaseServer}\${databaseToMount} on ${instanceName}..."
    Mount-NAVTenant -ServerInstance $instanceName -Tenant default -DatabaseName $databaseToMount -DatabaseServer $databaseServer
    $Tenant = Get-NAVTenant -ServerInstance $instanceName | Where-Object -Property Id -EQ default
    if (!($Tenant)) { Throw }

    Write-Host "Syncing database layout changes..."
    Sync-NAVTenant -ServerInstance $instanceName -Tenant default -Mode ForceSync -Force -CommitPerTable -ErrorAction Stop
    Get-NAVTenant -ServerInstance $instanceName -Tenant default
    
    Write-Host "Dismounting ${databaseToMount}..."
    Dismount-NAVTenant -ServerInstance $instanceName -Tenant default -Force
    
    Write-Host "Mounting database as ${tenantId} tenant ${databaseServer}\${databaseToMount} on ${instanceName}..."
    Mount-NAVTenant -ServerInstance $instanceName -Tenant $tenantId -DatabaseName $databaseToMount -DatabaseServer $databaseServer -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase -Force
    $Tenant = Get-NAVTenant -ServerInstance $instanceName | Where-Object -Property Id -EQ $tenantId
    if (!($Tenant)) { Throw }    
    Write-Host "Syncing database layout changes..."
    Sync-NAVTenant -ServerInstance $instanceName -Tenant $tenantId -Mode Sync -Force -CommitPerTable -ErrorAction Stop
    Get-NAVTenant -ServerInstance $instanceName -Tenant $tenantId


    UnLoad-InstanceAdminTools

    } -ArgumentList ($DeploymentSettings.instanceName, $DeploymentSettings.tenantId, $DeploymentSettings.databaseToMount)


$Session | Remove-PSSession