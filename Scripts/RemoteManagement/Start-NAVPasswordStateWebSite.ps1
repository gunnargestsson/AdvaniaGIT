Function Start-NAVPasswordStateWebSite {
    param(
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$PasswordId=""
    )
    if ($PasswordId -gt "") {
        $RemoteConfig = Get-NAVRemoteConfig
        if ($RemoteConfig.PasswordStateUrl -gt "") {
            Start-Process "$($RemoteConfig.PasswordStateUrl)/pid=$PasswordId"
        }
    }
}