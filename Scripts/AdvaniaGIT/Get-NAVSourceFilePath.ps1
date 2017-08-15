function Get-NAVSourceFilePath
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    $TempSourceFilePath = (Join-Path $SetupParameters.LogPath "Source.txt")
    $Sources = @()
    $Sources += (Get-ChildItem -Path $SetupParameters.SourcePath -File).Name
    if ($SetupParameters.ftpServer -ne "") {
        $Sources += Get-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -Directory "$($SetupParameters.navRelease)/"
    }
    $FilePatterns = @(
        "$($SetupParameters.navRelease)-$($SetupParameters.projectName).txt",
        "$($SetupParameters.navRelease)/$($SetupParameters.navVersion)/$($SetupParameters.projectName).txt",
        "$($SetupParameters.navRelease)/$($SetupParameters.projectName).txt",
        "$($SetupParameters.navRelease)-$($SetupParameters.navSolution).txt"
        "$($SetupParameters.navRelease)/$($SetupParameters.navVersion)/$($SetupParameters.navSolution).txt",
        "$($SetupParameters.navRelease)/$($SetupParameters.navSolution).txt")
    foreach ($FilePattern in $FilePatterns) {
        if ($Sources -imatch $FilePattern ) {
            if (Test-Path (Join-Path $SetupParameters.SourcePath $FilePattern)) {
                Copy-Item -Path (Join-Path $SetupParameters.SourcePath $FilePattern) -Destination $TempSourceFilePath -Force
            } else {
                Get-FtpFile `
                    -Server $SetupParameters.ftpServer `
                    -User $SetupParameters.ftpUser `
                    -Pass $SetupParameters.ftpPass `
                    -FtpFilePath $FilePattern `
                    -LocalFilePath $TempSourceFilePath
            }
            break
        }
    }
    if (Test-Path $TempSourceFilePath) {
        return $TempSourceFilePath
    } else {
        Show-Error -SetupParameters $SetupParameters -ErrorMessage "No Source found for $($SetupParameters.projectName)"
    }
}