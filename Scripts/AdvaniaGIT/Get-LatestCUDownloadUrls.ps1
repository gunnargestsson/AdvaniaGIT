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
    Download-NAVFile -Url $FeedUrl -FileName $FeedFilePath
    [xml]$Content = Get-Content $FeedFilePath 
    $Feed = $Content.feed

    $DownloadUrls = @()
    $SearchString = "Cumulative Update * for Microsoft Dynamics NAV $($SetupParameters.navRelease) has been released"
    ForEach ($item in $Feed.entry){ 
        Write-Verbose "Found article $($item.title.InnerText)..."

        if ($item.title.InnerText -like $SearchString) {
            Download-NAVFile -Url $item.link.Item(0).href -FileName $ArticlePath
            $Article = (Get-Content $ArticlePath | Out-String).Replace("<span>","")
            $endPos = 1
            while ($Article.IndexOf("http://download.microsoft.com/download", $endPos) -gt 0) {
                $startPos = $Article.IndexOf('http://download.microsoft.com/download', $endPos)
                $endPos = $Article.IndexOf('">', $startPos)
                $cuLink = $Article.Substring($startPos, $endPos - $startPos)
                $cuLocal = $Article.Substring($endPos + 2, 2)
                $DownloadUrls += @{"LocalVersion"=$cuLocal; "DownloadUrl"=$cuLink}
            }
            return $DownloadUrls
        }
    }
    return $DownloadUrls
}
