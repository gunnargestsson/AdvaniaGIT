Function Get-NAVLatestBlogArticle 
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
    Download-NAVFile -Url $FeedUrl -FileName $FeedFilePath
    [xml]$Content = Get-Content $FeedFilePath 
    $Feed = $Content.rss.channel

    $DownloadUrls = @()
    $SearchString = "Cumulative Update * for Microsoft Dynamics NAV $($SetupParameters.navRelease) has been released"
    ForEach ($item in $Feed.Item){ 
        Write-Verbose "Found article $($item.title)..."

        if ($item.title -like $SearchString) {
            return $item
        }
    }
}
