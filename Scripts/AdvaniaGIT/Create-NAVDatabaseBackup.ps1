function Create-NAVDatabaseBackup
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $TempBackupFilePath = Join-Path $LogPath "NAVBackup.bak"
    $command = "BACKUP DATABASE [$($BranchSettings.databaseName)] TO DISK = N'$TempBackupFilePath' WITH COPY_ONLY, COMPRESSION, NOFORMAT, INIT, NAME = N'NAVAPP_QA_MT-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
    Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database master -Command $command | Out-Null
    $BackupFilePath = Join-Path $BackupPath "$($SetupParameters.navRelease)-$($SetupParameters.projectName).bak"
    Move-Item -Path $TempBackupFilePath -Destination $BackupFilePath -Force
    Write-Host "Backup $BackupFilePath Created..."
}
    