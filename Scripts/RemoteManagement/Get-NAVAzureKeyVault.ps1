Function Get-NAVAzureKeyVault {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$VaultName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$ResourceGroupName
    )
    PROCESS 
    {    
        if ($VaultName.Length -gt 24) { $VaultName = $VaultName.Substring(0,24) }
        $KeyVault = Get-AzureRmKeyVault | Where-Object -Property VaultName -like $VaultName
        if (!$KeyVault) {
            if ([String]::IsNullOrEmpty($ResourceGroupName)) {
                $ResourceGroup = Get-NAVAzureResourceGroup -Message "No Key Vault found for $DeploymentName, Select a resource group for the Key Vault."
                $ResourceGroupName = $ResourceGroup.ResourceGroupName
            } else {
                $ResourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName 
            }
            if ([String]::IsNullOrEmpty($VaultName)) {
                $VaultName = "${DeploymentName}$($ResourceGroup.ResourceGroupName)"
            }
            if ($VaultName.Length -gt 24) { $VaultName = $VaultName.Substring(0,24) }
            if ($ResourceGroup) { 
                $KeyVault = New-AzureRmKeyVault -VaultName $VaultName -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $ResourceGroup.Location                 
            }
        }
        Return $KeyVault
    }
}