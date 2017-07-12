Function Set-NAVPasswordStateUser {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Title,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$UserName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$FullName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Password
    )
    $RemoteConfig = Get-NAVRemoteConfig
    $Headers = @{APIKey=$($RemoteConfig.NAVPasswordStateAPIKey)}
    try {
        $url = "$($RemoteConfig.PasswordStateUrl)/api/passwordlists/$($RemoteConfig.NAVPasswordStateListId)"
        $PasswordList = Invoke-RestMethod -Method Get -Uri $url -Headers $Headers -UseDefaultCredentials
    } catch {
        Write-Host -ForegroundColor Red "Password State password list no. $($RemoteConfig.NAVPasswordStateListId) is not accessible!"
        break
    }
    try {   
        $url = "$($RemoteConfig.PasswordStateUrl)/api/passwords"
        $Body = @{PasswordListID=$($PasswordList.PasswordListID);Title=$Title;UserName=$UserName;password=$Password;Description=$FullName;APIKey=$($RemoteConfig.NAVPasswordStateAPIKey)}
        $Response = Invoke-RestMethod -Method Post -Uri $url -UseDefaultCredentials -Body (ConvertTo-Json $Body) -ContentType "application/json;charset=utf-8"
        Write-Host "Password created in $($RemoteConfig.PasswordStateUrl)"
    }
    catch {
        Write-Host -ForegroundColor Red "Failed send password update to Password State Service!"
    }
    return $Response
    
}
