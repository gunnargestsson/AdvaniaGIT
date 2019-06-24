Function Get-LatestCUDownloadUrls 
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [String]$FeedUrl="https://blogs.msdn.microsoft.com/nav/feed/atom"
    )

    # Download RSS Feed
    $FeedFilePath = (Join-Path $SetupParameters.LogPath "Feed.xml")
    $ArticlePath = (Join-Path $SetupParameters.LogPath "Article.html")
    $DownloadPagePath = (Join-Path $SetupParameters.LogPath "Download.html")
    Download-NAVFile -Url $FeedUrl -FileName $FeedFilePath
    [xml]$Content = Get-Content $FeedFilePath 
    $Feed = $Content.feed

    $DownloadUrls = @()
    $SearchString = "Cumulative Update * for Microsoft Dynamics NAV $($SetupParameters.navRelease) *"
    ForEach ($item in $Feed.entry){ 
        Write-Verbose "Found article $($item.title)..."

        if ($item.title -like $SearchString) {
            Download-NAVFile -Url $item.link.href -FileName $ArticlePath
            $Article = (Get-Content $ArticlePath | Out-String).Replace("<span>","")			
            $endPos = 1
            if ($Article.IndexOf("http://www.microsoft.com/downloads/details.aspx?familyid=", $endPos) -gt 0) {
                $startPos = $Article.IndexOf('http://www.microsoft.com/downloads/details.aspx?familyid=', $endPos)
                $endPos = $Article.IndexOf('\"', $startPos)
                $DownloadUrl = $Article.Substring($startPos, $endPos - $startPos)    

                Download-NAVFile -Url $DownloadUrl -FileName $DownloadPagePath
                $DownloadPage = Get-Content $DownloadPagePath | Out-String
                $endPos = 1
                $startPos = $DownloadPage.IndexOf("confirmation.aspx?id=", $endPos)
                $endPos = $DownloadPage.IndexOf('" ', $startPos)
                $DownloadUrl = 'https://www.microsoft.com/en-us/download/' + $DownloadPage.Substring($startPos, $endPos - $startPos)

                Download-NAVFile -Url $DownloadUrl -FileName $DownloadPagePath
                $DownloadPage = Get-Content $DownloadPagePath | Out-String
                $endPos = 1
                $startPos = $DownloadPage.IndexOf('base_0:{url:"', $endPos)
                $endPos = $DownloadPage.IndexOf('/CU', $startPos) 
                $cuNumber = $item.title.Substring(18,2)             
                $DownloadUrl = ($DownloadPage.Substring($startPos, $endPos - $startPos)).Replace('base_0:{url:"','') + '/CU ' + $cuNumber + ' NAV 2018 ' + $SetupParameters.navSolution + '.zip' 
                            
                $DownloadUrls += @{"LocalVersion"=($SetupParameters.navSolution); "DownloadUrl"=$DownloadUrl}
            }
            return $DownloadUrls
        }
    }
    return $DownloadUrls
}
