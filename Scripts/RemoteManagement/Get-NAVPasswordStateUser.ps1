Function Get-NAVPasswordStateUser {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$PasswordId
    )
    try {
        $RemoteConfig = Get-RemoteConfig        
        $url = "$($RemoteConfig.PasswordStateUrl)/api/passwords/$($PasswordId)?apikey=$($RemoteConfig.NAVPasswordStateAPIKey)"
        $ResonseJson = Invoke-WebRequest -Uri $url -UseDefaultCredentials
        $Response = $ResonseJson | Out-String | ConvertFrom-Json
    }
    catch
    {
        $Response = New-Object -TypeName PSObject
        $Response | Add-Member -MemberType NoteProperty -Name PasswordID -Value $PasswordId
        $Response | Add-Member -MemberType NoteProperty -Name Title -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name Domain -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name HostName -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name UserName -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name Description -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name GenericField1 -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name GenericField2 -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name GenericField3 -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name GenericField4 -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name GenericField5 -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name GenericField6 -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name GenericField7 -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name GenericField8 -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name GenericField9 -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name GenericField10 -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name AccountTypeID -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name Notes -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name URL -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name Password -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name ExpiryDate -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name AllowExport -Value ""
        $Response | Add-Member -MemberType NoteProperty -Name AccountType -Value ""
    }
    return $Response
}
