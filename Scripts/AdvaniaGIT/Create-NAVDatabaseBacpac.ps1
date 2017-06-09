function Create-NAVDatabaseBacpac
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $TempBackupFilePath = Join-Path $SetupParameters.LogPath "NAVBackup.bacpac"

    $command = "DROP USER [NT AUTHORITY\NETWORK SERVICE]"
    $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command

    # 1. Get SQL Server Version 
    $SQLKey = Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL"   
    $SQLVersionNum = [regex]::Match($SQLKey.MSSQLSERVER, "\d\d").Value 
 
    # 2. Construct SqlPackage Path 
        $ToolPath = "C:\Program Files (x86)\Microsoft SQL Server\$($SQLVersionNum)0\DAC\bin" 
        $OldPath = Get-Location 
        Set-Location $ToolPath 
 
    # 3. Run SqlPackage tool to export bacpac file 
        .\SqlPackage.exe /a:Export /ssn:$(Get-DatabaseServer -BranchSettings $BranchSettings) /sdn:$($BranchSettings.databaseName) /tf:$TempBackupFilePath

    $command = "CREATE USER [NT AUTHORITY\NETWORK SERVICE] FOR LOGIN [NT AUTHORITY\NETWORK SERVICE] WITH DEFAULT_SCHEMA=[dbo]"
    $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command
    $command = "ALTER ROLE [db_owner] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]"
    $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command

    $BackupFilePath = Join-Path $SetupParameters.BackupPath "$($SetupParameters.navRelease)-$($SetupParameters.projectName).bacpac"
    
    if (!(Test-Path $TempBackupFilePath)) { Show-ErrorMessage -SetupParameters $SetupParameters -ErrorMessage "Failed to create bacpac" }
    Move-Item -Path $TempBackupFilePath -Destination $BackupFilePath -Force
    Write-Host "Backup $BackupFilePath Created..."
}
    