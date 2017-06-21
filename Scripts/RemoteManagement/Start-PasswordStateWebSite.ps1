Function Start-PasswordStateWebSite {
    param(
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$PasswordId=""
    )
    if ($PasswordId -gt "") {
        $RemoteConfig = Get-RemoteConfig
        if ($RemoteConfig.PasswordStateUrl -gt "") {
            Start-Process "$($RemoteConfig.PasswordStateUrl)/pid=$PasswordId"
        }
    }
}