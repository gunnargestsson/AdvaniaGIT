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
    $newAccountant | Add-Member -MemberType NoteProperty -Name Tenants -Value @()
    $newAccountants += $newAccountant
    $currentProvider.Accountants += $newAccountant
    $newProviders += $currentProvider
    $KontoConfig.Providers = $newProviders
    Update-NAVKontoConfig -KontoConfig $KontoConfig
    return $currentProvider
}