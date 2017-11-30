function Load-NAVKontoAccountantStartMenu
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Accountants
    )
    $menuItems = @()
    $AccountantNo = 1
    foreach ($Accountant in $Accountants) {
        $menuItem = $Accountant
        $menuItem | Add-Member -MemberType NoteProperty -Name No -Value $AccountantNo -Force
        $response = Get-NAVKontoResponse -Provider $Provider -Query "get-bookkeeper?guid=$($Accountant.guid)"
        if ($response.status -eq "True") {
            $accountantConfig = $response.result
            $menuItem = Combine-Settings $accountantConfig $menuItem
        }
        $menuItems += $menuItem
        $AccountantNo ++
    }    
    Return $menuItems
}

