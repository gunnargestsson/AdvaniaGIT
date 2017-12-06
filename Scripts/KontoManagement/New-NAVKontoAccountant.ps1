Function New-NAVKontoAccountant {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider
    )

    $KontoConfig = Get-NAVKontoConfig
    $instance = Get-NAVKontoRemoteInstance -DeploymentName $Provider.Deployment
    if ($instance -eq $null) {
        return
    }
    $guid = Read-Host -Prompt "Enter guid for new accountant"
    if ($guid -eq "") {
        return
    }
    $noOfUsers = Read-Host -Prompt "Enter no. of users for accountant"
    if ($noOfUsers -eq "") {
        return
    }
    
    $newProviders = @()
    $KontoConfig.Providers | Where-Object -Property ProviderId -NE $Provider.ProviderId | foreach {$newProviders += $_}
    $currentProvider = $KontoConfig.Providers | Where-Object -Property ProviderId -EQ $Provider.ProviderId
    $newAccountant = New-Object -TypeName PSObject
    $newAccountant | Add-Member -MemberType NoteProperty -Name guid -Value $guid
    $newAccountant | Add-Member -MemberType NoteProperty -Name noOfUsers -Value $noOfUsers
    $newAccountant | Add-Member -MemberType NoteProperty -Name Instance -Value $instance.ServerInstance
    $newAccountant | Add-Member -MemberType NoteProperty -Name PublicODataBaseUrl -Value "$($instance.PublicODataBaseUrl)?tenant=<tenant>"
    $newAccountant | Add-Member -MemberType NoteProperty -Name PublicSOAPBaseUrl -Value "$($instance.PublicSOAPBaseUrl)?tenant=<tenant>"
    $newAccountant | Add-Member -MemberType NoteProperty -Name PublicWebBaseUrl -Value "$($instance.PublicWebBaseUrl)365?tenant=<tenant>"
    $newAccountant | Add-Member -MemberType NoteProperty -Name Users -Value @()
    $newAccountant | Add-Member -MemberType NoteProperty -Name Tenants -Value @()

    if ($noOfUsers -gt 0) {
        For ($i=1; $i -le $noOfUsers; $i++) { 
            $UserEmailAddress = Read-Host -Prompt "Enter Office 365 Login Id (email address)"
            $AccountantUser = New-Object -TypeName PSObject
            $AccountantUser | Add-Member -MemberType NoteProperty -Name AuthenticationEmail -Value $UserEmailAddress
            $newAccountant.Users += $AccountantUser
        }
    }

    $newAccountants += $newAccountant
    $currentProvider.Accountants += $newAccountant
    $newProviders += $currentProvider
    $KontoConfig.Providers = $newProviders
    Update-NAVKontoConfig -KontoConfig $KontoConfig
    return $currentProvider
}