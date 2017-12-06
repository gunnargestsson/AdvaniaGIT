Function Rename-NAVKontoCompany {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$CompanyName
    )
    PROCESS 
    {

    $Result = Invoke-Command -Session $Session -ScriptBlock `
        {
            param(
                [String]$ServerInstance,
                [String]$TenantId,
                [String]$Company,
                [String]$NewCompany)
            Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
            Load-InstanceAdminTools -SetupParameters $SetupParameters
            Write-Host "Renaming company ${Company} to ${NewCompany}..."
            Rename-NAVCompany -ServerInstance $ServerInstance -Tenant $TenantId -CompanyName $Company -NewCompanyName $NewCompany -Force 
            UnLoad-InstanceAdminTools
        } -ArgumentList (
            $SelectedTenant.ServerInstance, 
            $SelectedTenant.Id, 
            $SelectedTenant.CompanyList[0],
            $CompanyName )
    }    
}