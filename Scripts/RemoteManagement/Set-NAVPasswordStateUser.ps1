Function Set-NAVPasswordStateUser {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Title,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$UserName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Password
    )
    try {
        $RemoteConfig = Get-RemoteConfig        
        $url = "$($RemoteConfig.PasswordStateUrl)/api/passwords/$($PasswordId)?apikey=$($RemoteConfig.NAVPasswordStateAPIKey)"
        $url += "&PasswordList=$($RemoteConfig.NAVPasswordStateListId)"
        $url += "&Title=$([System.Web.HttpUtility]::UrlEncode($Title))"
        $url += "&UserName=$[System.Web.HttpUtility]::UrlEncode($UserName))"
        $url += "&Password=$[System.Web.HttpUtility]::UrlEncode($Password))"       
        $ResonseJson = Invoke-WebRequest -Uri $url -UseDefaultCredentials -Method Post
        $Response = ($ResonseJson | Out-String | ConvertFrom-Json).PasswordID
    }
    catch {
        Write-Host -ForegroundColor Red "Failed send password update to Password State Service!"
    }
    return $Response
    
}
