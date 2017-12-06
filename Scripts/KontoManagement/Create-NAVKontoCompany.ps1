Function Create-NAVKontoCompany {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Accountant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$TenantConfig
    )

    $Session = Get-NAVKontoRemoteSession -Provider $Provider

    if ($TenantConfig.name.Length -gt 30) {
        $companyName = $TenantConfig.name.SubString(0,30)
    } else {
        $companyName = $TenantConfig.name
    }

    if (!$TenantConfig.CompanyList.Contains($companyName)) {
        Rename-NAVKontoCompany -Session $Session -SelectedTenant $TenantConfig -CompanyName $companyName
    }

    Remove-PSSession -Session $Session
}