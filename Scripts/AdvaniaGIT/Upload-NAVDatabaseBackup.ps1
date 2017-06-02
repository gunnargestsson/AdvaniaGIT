function Upload-NAVDatabaseBackup
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    if ($env:bamboo_build_working_directory) {
        $BackupFilePath = Join-Path $env:bamboo_build_working_directory "$($SetupParameters.navRelease)-$($SetupParameters.projectName).bak"
    } else {
        $BackupFilePath = Join-Path $SetupParameters.BackupPath "$($SetupParameters.navRelease)-$($SetupParameters.projectName).bak"
    }
    if (Test-Path $BackupFilePath) { 
        $FtpFileName = ((Get-Item -Path $BackupFilePath).Name).Replace("-","/")
        Put-FtpFile  `
            -Server $SetupParameters.ftpServer `
            -User $SetupParameters.ftpUser `
            -Pass $SetupParameters.ftpPass `
            -FtpFilePath $FtpFileName `
            -LocalFilePath $BackupFilePath
        Write-Verbose -Message "File $BackupFilePath uploaded..."
    }    
}
    