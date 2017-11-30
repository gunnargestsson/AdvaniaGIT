Function Post-NAVKontoResponse {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Query,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Content
    )
    try {
        $Credentials = Get-NAVPasswordStateUser -PasswordId $Provider.ProviderAuthentication
        $url = "$($Provider.KontoServiceUrl)${Query}"
        if ($url.Contains("?")) {
            $url = "$Url&"
        } else {
            $url = "$Url?"
        }
        $Url = $Url + "username=$($Credentials.UserName)&api_key=$($Credentials.Password)"
        $Response = Invoke-RestMethod -Method Post -Uri $url -Body $Content 
    }
    catch
    {
    }
    return $Response
}
