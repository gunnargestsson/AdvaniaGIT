Function Get-NAVAzureKeyVaultKey {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$KeyVault,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$ServerInstanceName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$TenantId

    )
    PROCESS 
    {    
        
        if ($TenantId) {
            $KeyName = [Uri]::EscapeDataString("$($ServerInstanceName.Replace("_","-"))-$TenantId")            
        } else {
            $KeyName = [Uri]::EscapeDataString($ServerInstanceName.Replace("_","-"))
        }
        $KeyVaultKey = Get-AzureKeyVaultKey -VaultName $KeyVault.VaultName -Name $KeyName
        if (!$KeyVaultKey) {            
            $KeyVaultKey = Add-AzureKeyVaultKey -VaultName $KeyVault.VaultName -Name $KeyName -Destination Software 
        }
        Return $KeyVaultKey
    }
}