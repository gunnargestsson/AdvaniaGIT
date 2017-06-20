Function Get-NewUserPassword {

    [Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
    do {
        $pwd = [System.Web.Security.Membership]::GeneratePassword(15,2)
    } until ($pwd -match '\d')
    return $pwd
}