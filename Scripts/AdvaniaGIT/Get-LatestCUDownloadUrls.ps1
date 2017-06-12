Function Get-LatestCUDownloadUrls 
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [String]$FeedUrl="https://blogs.msdn.microsoft.com/nav/feed/"
    )

    # Download RSS Feed
    $FeedFilePath = (Join-Path $SetupParameters.LogPath "Feed.xml")
    $ArticlePath = (Join-Path $SetupParameters.LogPath "Article.html")
    Download-File -Url $FeedUrl -FileName $FeedFilePath
    [xml]$Content = Get-Content $FeedFilePath 
    $Feed = $Content.rss.channel

    $DownloadUrls = @()
    $SearchString = "Cumulative Update * for Microsoft Dynamics NAV $($SetupParameters.navRelease) has been released"
    ForEach ($item in $Feed.Item){ 
        Write-Verbose "Found article $($item.title)..."

        if ($item.title -like $SearchString) {
            Download-File -Url $item.link -FileName $ArticlePath
            $Article = Get-Content $ArticlePath | Out-String
            $endPos = 1
            while ($Article.IndexOf("http://download.microsoft.com/download", $endPos) -gt 0) {
                $startPos = $Article.IndexOf('http://download.microsoft.com/download', $endPos)
                $endPos = $Article.IndexOf('">', $startPos)
                $cuLink = $Article.Substring($startPos, $endPos - $startPos)
                $startPos = $Article.IndexOf('">', $endPos + 1)
                $endPos = $Article.IndexOf(' ', $startPos)
                $cuLocal = $Article.Substring($startPos + 2, $endPos - $startPos - 2)
                $DownloadUrls += @{"LocalVersion"=$cuLocal.Substring(0,2); "DownloadUrl"=$cuLink}
            }
            return $DownloadUrls
        }
    }
    return $DownloadUrls
}
