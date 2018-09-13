Function Get-NAVUserPasswordObject {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Usage
    )
    $RemoteConfig = Get-NAVRemoteConfig
    if ([bool]($RemoteConfig.PSObject.Properties.name -match $Usage)) {
        $PasswordId = $RemoteConfig.$Usage
        $Response = Get-NAVPasswordStateNAVUser -PasswordId $PasswordId
    } else {
        $Response = New-NAVAuthenticationDialog -Usage $Usage   
    }
    return $Response
}
