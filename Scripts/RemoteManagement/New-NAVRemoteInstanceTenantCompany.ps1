Function New-NAVRemoteInstanceTenantCompany {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
    PROCESS 
    {
        $NewCompany = New-NAVCompanyDialog -Message "Enter new company name." -Company (New-NAVCompanyObject)
        if ($NewCompany.CompanyName -eq "") { Return $NewCompany }   
        if ($NewCompany.OKPressed -ne 'OK') { Return $NewCompany }  
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param(
                    [String]$ServerInstance,
                    [String]$TenantId,
                    [String]$Company)
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                Write-Host "Creating company ${Company}..."
                New-NAVCompany -Tenant $TenantId -CompanyName $Company -ServerInstance $ServerInstance
                UnLoad-InstanceAdminTools
            } -ArgumentList (
                $SelectedTenant.ServerInstance, 
                $SelectedTenant.Id, 
                $NewCompany.CompanyName) 
        
        Return $NewCompany
    }    
}