Function Get-NAVAzureKeyVaultKey {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$KeyVault,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$ServerInstanceName
    )
    PROCESS 
    {    
        $KeyVaultKey = Get-AzureKeyVaultKey -VaultName $KeyVault.VaultName -Name $ServerInstanceName        
        if (!$KeyVaultKey) {            
            $KeyVaultKey = Add-AzureKeyVaultKey -VaultName $KeyVault.VaultName -Name $ServerInstanceName -Destination Software 
        }
        Return $KeyVaultKey
    }
}