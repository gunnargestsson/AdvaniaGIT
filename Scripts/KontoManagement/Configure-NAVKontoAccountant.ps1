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
        $menuItems | Format-Table -Property No, Name, Registration_No, Email, Status, Message, Availability -AutoSize 
        $input = Read-Host "Please select tenant number (0 = exit, + = add tenant)"
        switch ($input) {
            '0' { break }
            '+' { $Accountant = New-NAVKontoTenant -Provider $Provider -Accountant $Accountant }
            default {
                $selectedTenant = $menuItems | Where-Object -Property No -EQ $input
                if ($selectedTenant) { 
                    Configure-NAVKontoTenant -Provider $Provider -Accountant $Accountant -Tenant $selectedTenant
                }
            }
        }
    }
    until ($input -eq '0')        
}