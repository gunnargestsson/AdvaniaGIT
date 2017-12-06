Function Get-NAVKontoResponse {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Query
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
        $Response = Invoke-RestMethod -Method Get -Uri $url -ContentType "application/json;charset=utf-8"
    }
    catch
    {
    }
    return $Response
}
