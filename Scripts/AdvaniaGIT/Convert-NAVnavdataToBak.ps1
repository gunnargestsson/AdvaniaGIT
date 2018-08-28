Function Convert-NAVnavdataToBak
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )

    $SelectedNavdataFile = Get-LocalNavdataFilePath
    if (Test-Path $SelectedNavdataFile.FullName) {  
        Write-Host "Creating temporary database..."
        $tempDatabaseName = New-Guid
        New-NAVEmptyDatabase -SetupParameters $SetupParameters -DatabaseName $tempDatabaseName
        Load-InstanceAdminTools -SetupParameters $SetupParameters
        Import-NAVData `
            -DatabaseServer (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) `
            -DatabaseName $tempDatabaseName `
            -FilePath $SelectedNavdataFile.FullName `
            -IncludeApplication `
            -IncludeApplicationData `
            -IncludeGlobalData `
            -AllCompanies `
            -Force
        UnLoad-InstanceAdminTools
        $TempBackupFilePath = Join-Path $SetupParameters.LogPath "NAVBackup.bak"
        $command = "select @@version as [Version]"
        $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command
        if ($result.Version -imatch 'Express') {
            $command = "BACKUP DATABASE [$tempDatabaseName] TO DISK = N'$TempBackupFilePath' WITH COPY_ONLY, NOFORMAT, INIT, NAME = N'NAVAPP_QA_MT-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
        } else {
            $command = "BACKUP DATABASE [$tempDatabaseName] TO DISK = N'$TempBackupFilePath' WITH COPY_ONLY, COMPRESSION, NOFORMAT, INIT, NAME = N'NAVAPP_QA_MT-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
        }
        Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database master -Command $command | Out-Null
        Write-Host "Removing temporary database..."
        Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command "ALTER DATABASE [$tempDatabaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$tempDatabaseName]" | Out-Null                                        
        return $TempBackupFilePath
    }
}