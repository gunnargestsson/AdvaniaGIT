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
    $Backups = @()
    $Backups += (Get-ChildItem -Path $BackupPath -File).Name
    if ($SetupParameters.ftpServer -ne "") {
        $Backups += Get-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -Directory "$($SetupParameters.navRelease)/"
    }
    $FilePatterns = @(
        "$($SetupParameters.navRelease)-$($SetupParameters.projectName).bak",
        "$($SetupParameters.navRelease)/$($SetupParameters.navVersion)/$($SetupParameters.projectName).bak",
        "$($SetupParameters.navRelease)/$($SetupParameters.projectName).bak",
        "$($SetupParameters.navRelease)-$($SetupParameters.navSolution).bak"
        "$($SetupParameters.navRelease)/$($SetupParameters.navVersion)/$($SetupParameters.navSolution).bak",
        "$($SetupParameters.navRelease)/$($SetupParameters.navSolution).bak")
    foreach ($FilePattern in $FilePatterns) {
        if ($Backups -imatch $FilePattern ) {
            if (Test-Path (Join-Path $BackupPath $FilePattern)) {
                Copy-Item -Path (Join-Path $BackupPath $FilePattern) -Destination $TempBackupFilePath -Force
            } else {
                Get-FtpFile `
                    -Server $SetupParameters.ftpServer `
                    -User $SetupParameters.ftpUser `
                    -Pass $SetupParameters.ftpPass `
                    -FtpFilePath $FilePattern `
                    -LocalFilePath $TempBackupFilePath
            }
            break
        }
    }
    if (Test-Path $TempBackupFilePath) {
        return $TempBackupFilePath
    } else {
        Write-Error "No backup found for $($SetupParameters.projectName)" -ErrorAction Stop
    }
}