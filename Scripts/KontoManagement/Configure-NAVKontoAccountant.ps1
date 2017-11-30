Function Configure-NAVKontoAccountant {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Accountant
    )
    do {
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems = Load-NAVKontoTenantStartMenu -Provider $Provider -Tenants $Accountant.Tenants
        $menuItems | Format-Table -Property No, Name, Status, Message -AutoSize 
        $input = Read-Host "Please select tenant number (0 = exit, + = add tenant)"
        switch ($input) {
            '0' { break }
            '+' {  }
            default {
                $selectedTenant = $menuItems | Where-Object -Property No -EQ $input
                if ($selectedTenant) { 
                    ## Select Action for tenant
                }
            }
        }
    }
    until ($input -eq '0')        
}