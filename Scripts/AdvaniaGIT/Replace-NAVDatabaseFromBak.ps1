Function Replace-NAVDatabaseFromBak
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$SelectedBackupFile
     )

    if (Test-Path $SelectedBackupFile) {
        Load-InstanceAdminTools -SetupParameters $SetupParameters
        Write-Host "Stopping Service..."
        Set-NAVServerInstance -ServerInstance $BranchSettings.InstanceName -Stop
        Start-Sleep -Seconds 2
        Write-Host "Removing Database..."
        Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database master -Command "ALTER DATABASE [$($BranchSettings.DatabaseName)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$($BranchSettings.DatabaseName)]" | Out-Null
        $params = @{ 
            BackupFilePath = $SelectedBackupFile
            DatabaseServer = $BranchSettings.databaseServer
            DatabaseName = $BranchSettings.databaseName
            DatabasePath = $SetupParameters.DatabasePath }
        if ($BranchSettings.databaseInstance -ne "") { $params.DatabaseInstance = $BranchSettings.databaseInstance }
        Write-Host "Restoring database..."
        Restore-NAVBackup @params
        Write-Host "Upgrading database..."
        Invoke-NAVDatabaseConversion -SetupParameters $SetupParameters -BranchSettings $BranchSettings
        Write-Host "Compiling Service Objects..."
        Compile-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Filter "Type=Table;Id=2000000004..2000000999" -SynchronizeSchemaChanges No 
        Write-Host "Starting Service..."
        Set-NAVServerInstance -ServerInstance $BranchSettings.InstanceName -Start -Force 
        Write-Host "Syncronizing Database..."
        Get-NAVServerInstance -ServerInstance $BranchSettings.InstanceName | Where-Object -Property State -EQ Running | Sync-NAVTenant -Mode ForceSync -Force
        UnLoad-InstanceAdminTools
    }
}