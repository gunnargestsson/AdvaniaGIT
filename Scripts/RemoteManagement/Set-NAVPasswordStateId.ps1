Function Set-NAVPasswordStateId {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$PasswordId,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Password
    )
    try {
        $RemoteConfig = Get-RemoteConfig        
        $url = "$($RemoteConfig.PasswordStateUrl)/api/passwords"
        $Body = @{PasswordID=$($PasswordId);Password=$Password;APIKey=$($RemoteConfig.NAVPasswordStateAPIKey)}
        $Response = Invoke-RestMethod -Method Put -Uri $url -UseDefaultCredentials -Body (ConvertTo-Json $Body) -ContentType "application/json;charset=utf-8"
        Write-Host "Password updated in $($RemoteConfig.PasswordStateUrl)"
    }
    catch {
        Write-Host -ForegroundColor Red "Failed send password update to Password State Service!"
    }
    return $Response
    
}