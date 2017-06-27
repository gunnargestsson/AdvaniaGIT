Function Load-NAVRemoteInstanceTenantCompanyMenu {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )

    $CompanyNo = 1
    $Companies = @()
    foreach ($Company in (Get-NAVRemoteInstanceTenantCompanies -Session $Session -SelectedTenant $SelectedTenant)) {
        $Company | Add-Member -MemberType NoteProperty -Name No -Value $CompanyNo
        $CompanyNo ++
        $Companies += $Company
    }
    return $Companies
}