Function Configure-NAVKontoTenant {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Accountant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Tenant
    )

    PROCESS {
        $Tenantconfig = Load-NAVKontoTenantConfig -Provider $Provider -Accountant $Accountant -Tenant $Tenant
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $Tenantconfig | Format-Table -Property Registration_No, Name, State, CompanyList, UserList -AutoSize 
        $input = Read-Host "Please select action (0 = exit, 1 = create NAV tenant, 2 = rename NAV company, 3 = Create NAV users, 4 = Create company setup)"
        switch ($input) {
            '0' { break }
            '1' { Create-NAVKontoTenant -Provider $Provider -Accountant $Accountant -TenantConfig $Tenantconfig }
            '2' { Create-NAVKontoCompany -Provider $Provider -Accountant $Accountant -TenantConfig $Tenantconfig }
            '3' { Create-NAVKontoUsers -Provider $Provider -Accountant $Accountant -TenantConfig $Tenantconfig }
            '4' { Create-NAVKontoCompanyData  -Provider $Provider -Accountant $Accountant -TenantConfig $Tenantconfig }
        }
        $Tenantconfig = $null
    }
}