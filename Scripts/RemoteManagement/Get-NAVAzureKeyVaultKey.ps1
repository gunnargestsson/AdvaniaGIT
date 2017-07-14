Function Get-NAVAzureKeyVaultKey {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$KeyVault,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$ServerInstanceName
    )
    PROCESS 
    {    
        $KeyName = [Uri]::EscapeDataString($ServerInstanceName.Replace("_","-"))
        $KeyVaultKey = Get-AzureKeyVaultKey -VaultName $KeyVault.VaultName -Name $KeyName
        if (!$KeyVaultKey) {            
            $KeyVaultKey = Add-AzureKeyVaultKey -VaultName $KeyVault.VaultName -Name $KeyName -Destination Software 
        }
        Return $KeyVaultKey
    }
}