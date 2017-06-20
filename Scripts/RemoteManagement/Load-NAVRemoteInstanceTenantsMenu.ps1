Function Load-NAVRemoteInstanceTenantsMenu {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )
    PROCESS 
    {    
        $tenantNo = 1
        $tenants = @()        
        Foreach ($tenant in $SelectedInstance.TenantList) {
          $tenant | Add-Member -MemberType NoteProperty -Name No -Value $tenantNo
          $tenantNo ++
          $tenants += $tenant
        }
        return $tenants        
    }
}