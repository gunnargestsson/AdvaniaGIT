Function Get-NAVAzureKeyVault {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    {    
        
        $KeyVault = Get-AzureRmKeyVault | Where-Object -Property VaultName -like "${DeploymentName}*"
        if (!$KeyVault) {
            $ResourceGroup = Get-NAVAzureResourceGroup -Message "No Key Vault found for $DeploymentName, Select a resource group for the Key Vault."
            $VaultName = "${DeploymentName}$($ResourceGroup.ResourceGroupName)"
            if ($VaultName.Length -gt 24) { $VaultName = $VaultName.Substring(0,24) }
            if ($ResourceGroup) { 
                $KeyVault = New-AzureRmKeyVault -VaultName $VaultName -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $ResourceGroup.Location                 
            }
        }
        Return $KeyVault
    }
}