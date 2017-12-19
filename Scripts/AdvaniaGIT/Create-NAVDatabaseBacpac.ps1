function Create-NAVDatabaseBacpac
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$BacpacFilePath
    )
    $TempBacpacFilePath = Join-Path $SetupParameters.LogPath "NAVBackup.bacpac"

    $command = "DROP USER [NT AUTHORITY\NETWORK SERVICE]"
    $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command

    $command = "DELETE FROM [dbo].[Session Event]; DELETE FROM [dbo].[Active Session]; DELETE FROM [dbo].[Server Instance]"
    $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command

    $SqlPackagePath = Get-SqlPackagePath
    if (!(Test-Path $SqlPackagePath)) {
        Write-Host -ForegroundColor Red "SQL Package executable not found!"
        throw
    }

    Write-Host "Starting Database Export (will take some time)..."
    & $SqlPackagePath /a:Export /ssn:$(Get-DatabaseServer -BranchSettings $BranchSettings) /sdn:$($BranchSettings.databaseName) /tf:$TempBacpacFilePath

    $command = "CREATE USER [NT AUTHORITY\NETWORK SERVICE] FOR LOGIN [NT AUTHORITY\NETWORK SERVICE] WITH DEFAULT_SCHEMA=[dbo]"
    $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command
    $command = "ALTER ROLE [db_owner] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]"
    $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command

    if (!$BacpacFilePath) { $BacpacFilePath = Join-Path $SetupParameters.BackupPath "$($SetupParameters.navRelease)-$($SetupParameters.projectName).bacpac" }    
    if (!(Test-Path $TempBacpacFilePath)) {
        Write-Host -ForegroundColor Red "Failed to create bacpac" 
        throw
    }
    Move-Item -Path $TempBacpacFilePath -Destination $BacpacFilePath -Force
    Write-Host "Backup $BacpacFilePath Created..."
}
    