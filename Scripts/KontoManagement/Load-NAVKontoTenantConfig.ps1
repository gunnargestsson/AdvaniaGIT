Function Load-NAVKontoTenantConfig {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Accountant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Tenant
    )
    $Session = Get-NAVKontoRemoteSession -Provider $Provider 
    $NAVInstance = Get-NAVRemoteInstance -Session $Session -ServerInstanceName $Accountant.Instance -Tenants $True -TenantCompanies $True
    $NAVTenant = $NAVInstance.TenantList | Where-Object -Property Id -EQ $Tenant.registration_no
    if ($NAVTenant -eq $null) {
        $TenantConfig = $Tenant
        $TenantConfig | Add-Member -MemberType NoteProperty -Name State -Value "Not Configured"
        $TenantConfig | Add-Member -MemberType NoteProperty -Name CompanyList -Value @()
        $TenantConfig | Add-Member -MemberType NoteProperty -Name UserList -Value @()
    } else {
        $UserList = Get-NAVRemoteInstanceTenantUsers -Session $Session -SelectedTenant $NAVTenant 
        $NAVTenant | Add-Member -MemberType NoteProperty -Name UserList -Value $UserList.AuthenticationEmail
        $TenantConfig = Combine-Settings $Tenant $NAVTenant        
    }

    Remove-PSSession -Session $Session           
    return $TenantConfig
}