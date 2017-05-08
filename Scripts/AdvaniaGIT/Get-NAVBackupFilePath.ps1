function Get-NAVBackupFilePath
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $TempBackupFilePath = (Join-Path $LogPath "NAVBackup.bak")
    $BackupFilePath = (Join-Path $BackupPath ("$($SetupParameters.navRelease)-$($SetupParameters.projectName).bak"))
    if (Test-Path $BackupFilePath) {
        Copy-Item -Path $BackupFilePath -Destination $TempBackupFilePath -Force
    } else {
        $BackupFilePath = (Join-Path $BackupPath ("$($SetupParameters.navRelease)$($SetupParameters.navSolution).bak"))
        if (Test-Path $BackupFilePath) {
            Copy-Item -Path $BackupFilePath -Destination $TempBackupFilePath -Force
        } else {
            $FtpDirectory = Get-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -Directory "$($SetupParameters.navRelease)/"
            $FtpFiles = @(
              "$($SetupParameters.navRelease)/$($SetupParameters.navVersion)/$($SetupParameters.projectName).bak",
              "$($SetupParameters.navRelease)/$($SetupParameters.projectName).bak",
              "$($SetupParameters.navRelease)/$($SetupParameters.navVersion)/$($SetupParameters.navSolution).bak",
              "$($SetupParameters.navRelease)/$($SetupParameters.navSolution).bak")
            foreach ($FtpFile in $FtpFiles) {
                if ($FtpDirectory -imatch $FtpFile ) {
                    Get-FtpFile `
                        -Server $SetupParameters.ftpServer `
                        -User $SetupParameters.ftpUser `
                        -Pass $SetupParameters.ftpPass `
                        -FtpFilePath $FtpFile `
                        -LocalFilePath $TempBackupFilePath
                    break
                }
            }
        }
    }
    if (Test-Path $TempBackupFilePath) {
        return $TempBackupFilePath
    } else {
        Write-Error "No backup found for $($SetupParameters.navRelease)/$($SetupParameters.navVersion)/$($SetupParameters.navSolution)" -ErrorAction Stop
    }
}