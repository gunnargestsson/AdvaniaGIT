function Load-NAVKontoStartMenu
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$KontoConfig
    )
    $menuItems = @()
    $providerNo = 1
    foreach ($provider in $KontoConfig.Providers) {
        $menuItem = $provider
        $menuItem | Add-Member -MemberType NoteProperty -Name No -Value $providerNo -Force
        $menuItems += $menuItem
        $providerNo ++
    }    
    Return $menuItems
}

