Function Download-LatestNAVUpdate
{
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$Language = "W1",
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$InstallWorkFolder
    )
    BEGIN
    {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }
    PROCESS
    {
        Write-Host "Downloading CU information from Microsoft Blog..."
        $DownloadUrls = Get-LatestCUDownloadUrls -SetupParameters $SetupParameters 
        
        Write-Host "Downloading installation for $($SetupParameters.navRelease) $($Language)..."

        $DownloadUrl = ($DownloadUrls | Where-Object -Property LocalVersion -EQ $Language).DownloadUrl
        if ($DownloadUrl) {
            $DownloadFileName = Split-Path $DownloadUrl -Leaf

            $zipFile = Join-Path $SetupParameters.DownloadPath $DownloadFileName
            New-Item -Path $SetupParameters.DownloadPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
            if (Test-Path $zipFile) {
                Write-Host "$DownloadFileName already downloaded..."
            } else {
                Download-File -Url $DownloadUrl -FileName $zipFile
            }

            Write-Host "Extracting $zipFile to $($InstallWorkFolder)..."        
            Remove-Item -Path $installWorkFolder -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $installWorkFolder -ItemType Directory | Out-Null
            [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $installWorkFolder)
            $tempZipFile = Get-ChildItem -Path $installWorkFolder -Filter "NAV*.zip"
            [System.IO.Compression.ZipFile]::ExtractToDirectory($tempZipFile.FullName, $installWorkFolder) 
            Remove-Item -Path $tempZipFile.FullName -Force -Recurse
        } else {
            Show-Error -SetupParameters $SetupParameters -ErrorMessage "No url found for language $($Language)"
        }
    }
}