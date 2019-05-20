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
        $pageId = 1
        while (!$DownloadUrls) {
            $DownloadUrls = Get-LatestCUDownloadUrls -SetupParameters $SetupParameters -FeedUrl "https://support.microsoft.com/app/content/api/content/feeds/sap/en-gb/dea12e4a-4dd3-35e1-2577-45df252a2b9c/atom"
            if ($pageId -gt 10) { 
                Write-Host -ForegroundColor Red "Download Urls for $($SetupParameters.navRelease) not found!"
                throw
            }
            $PageId ++
        }
        Write-Host "Downloading installation for $($SetupParameters.navRelease) $($Language)..."

        $DownloadUrl = ($DownloadUrls | Where-Object -Property LocalVersion -EQ $Language).DownloadUrl
        if (!$DownloadUrl) {
            $DownloadUrl = ($DownloadUrls | Where-Object -Property LocalVersion -EQ "W1").DownloadUrl
        }
        if ($DownloadUrl) {
            $DownloadFileName = Split-Path $DownloadUrl -Leaf

            $zipFile = Join-Path $SetupParameters.DownloadPath $DownloadFileName
            New-Item -Path $SetupParameters.DownloadPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
            if (Test-Path $zipFile) {
                Write-Host "$DownloadFileName already downloaded..."
            } else {
                Download-NAVFile -Url $DownloadUrl -FileName $zipFile
            }

            Write-Host "Extracting $zipFile to $($InstallWorkFolder)..."        
            Remove-Item -Path $installWorkFolder -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $installWorkFolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
            [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $installWorkFolder)
            $tempZipFile = Get-ChildItem -Path $installWorkFolder -Filter "NAV*.zip"
            [System.IO.Compression.ZipFile]::ExtractToDirectory($tempZipFile.FullName, $installWorkFolder) 
            Remove-Item -Path $tempZipFile.FullName -Force -Recurse
        } else {
            Show-Error -SetupParameters $SetupParameters -ErrorMessage "No url found for language $($Language)"
        }
    }
}