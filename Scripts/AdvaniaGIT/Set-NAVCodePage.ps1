Function Set-NAVCodePage
{
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )

    
    if (![String]::IsNullOrEmpty($SetupParameters.filesEncoding)) {
        $chcp = ($SetupParameters.filesEncoding) -replace '\D+(\d+)','$1'
    } else {
        $chcp = '850'
    }    
    try {chcp $chcp}
    catch {}
}
