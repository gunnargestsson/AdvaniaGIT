Function Rename-NAVRemoteInstanceTenantCompany {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedCompany
    )
    PROCESS 
    {
        $NewCompany = Read-Host -Prompt "Type new name for the company"
        if ($NewCompany -ne "") {
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
                    $SelectedCompany.CompanyName,
                    $NewCompany )
        }
        Return $Company
    }    
}