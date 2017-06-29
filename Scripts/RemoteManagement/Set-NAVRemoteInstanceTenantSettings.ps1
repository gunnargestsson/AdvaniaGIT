Function Set-NAVRemoteInstanceTenantSettings {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
    PROCESS 
    {  
        $TenantSettings = Invoke-Command -Session $Session -ScriptBlock `
            {
                param([PSObject]$SelectedTenant)
                $TenantSettings = Update-TenantSettings -Tenant $SelectedTenant
                Return $TenantSettings
            } -ArgumentList $SelectedTenant
               
        Return $TenantSettings
    }    
}