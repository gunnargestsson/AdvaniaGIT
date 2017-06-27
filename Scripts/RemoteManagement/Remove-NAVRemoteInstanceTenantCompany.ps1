Function Remove-NAVRemoteInstanceTenantCompany {
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
        $ConfirmedCompany = Read-Host -Prompt "Type the name of the company to be removed"
        if ($SelectedCompany.CompanyName -ieq $ConfirmedCompany) {
            $Result = Invoke-Command -Session $Session -ScriptBlock `
                {
                    param(
                        [String]$ServerInstance,
                        [String]$TenantId,
                        [String]$Company)
                    Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                    Load-InstanceAdminTools -SetupParameters $SetupParameters
                    Write-Host "Removing company ${Company}..."
                    Remove-NAVCompany -ServerInstance $ServerInstance -Tenant $TenantId -CompanyName $Company -Force
                    UnLoad-InstanceAdminTools
                } -ArgumentList (
                    $SelectedTenant.ServerInstance, 
                    $SelectedTenant.Id, 
                    $SelectedCompany.CompanyName )
        }
        Return $Company
    }    
}