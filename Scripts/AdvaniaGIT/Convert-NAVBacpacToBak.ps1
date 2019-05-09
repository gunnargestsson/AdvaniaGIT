Function Convert-NAVBacpacToBak
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )

    $SelectedBacpacFile = Get-LocalBacpacFilePath
    if (Test-Path $SelectedBacpacFile.FullName) {  
        Write-Host "Creating temporary database..."
        $tempDatabaseName = New-Guid
        $SqlPackagePath = Get-SqlPackagePath
        $Arguments = @("/action:Import /sourcefile:""$($SelectedBacpacFile.FullName)"" /targetservername:$(Get-DatabaseServer -BranchSettings $BranchSettings) /targetdatabasename:${tempDatabaseName}")
        Start-Process -FilePath $SqlPackagePath -ArgumentList @Arguments -NoNewWindow -Wait -ErrorAction Stop
        $TempBackupFilePath = Join-Path $SetupParameters.LogPath "NAVBackup.bak"
        $command = "select @@version as [Version]"
        $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
        if ($result.Version -imatch 'Express') {
            $command = "BACKUP DATABASE [$tempDatabaseName] TO DISK = N'$TempBackupFilePath' WITH COPY_ONLY, NOFORMAT, INIT, NAME = N'NAVAPP_QA_MT-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
        } else {
            $command = "BACKUP DATABASE [$tempDatabaseName] TO DISK = N'$TempBackupFilePath' WITH COPY_ONLY, COMPRESSION, NOFORMAT, INIT, NAME = N'NAVAPP_QA_MT-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
        }
        Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database master -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword | Out-Null
        Write-Host "Removing temporary database..."
        Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command "ALTER DATABASE [$tempDatabaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$tempDatabaseName]" -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword | Out-Null                                        
        return $TempBackupFilePath
    }
}