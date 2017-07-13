Function Delete-NAVPasswordStateId {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$PasswordId
    )
    try {
        $RemoteConfig = Get-NAVRemoteConfig        
        $url = "$($RemoteConfig.PasswordStateUrl)/api/passwords/${PasswordId}?APIKey=$($RemoteConfig.NAVPasswordStateAPIKey)&MoveToRecycleBin=True"
        $Response = Invoke-RestMethod -Method Delete -Uri $url -UseDefaultCredentials 
        Write-Host "Password deleted from $($RemoteConfig.PasswordStateUrl)"
    }
    catch {
        Write-Host -ForegroundColor Red "Failed send password delete to Password State Service!"
    }
    return $Response
    
}
