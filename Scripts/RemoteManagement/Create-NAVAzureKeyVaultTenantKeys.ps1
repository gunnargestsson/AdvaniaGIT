Function Create-NAVAzureKeyVaultTenantKeys 
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$KeyVault,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$ServerInstance
    )
    PROCESS 
    {    
        $TenantKeyList = @()
        if ($ServerInstance.Multitenant -ieq "true") {
            Write-Verbose "Creating Tenants Keys..."
            Foreach ($tenant in $ServerInstance.TenantList) {                
                $TenantKeyVaultKey = Get-NAVAzureKeyVaultKey -KeyVault $KeyVault -ServerInstanceName $ServerInstance.ServerInstance -TenantId $tenant.Id
                $TenantKeyList += Combine-Settings $tenant $TenantKeyVaultKey
                }
        }
        return $TenantKeyList
    }
}