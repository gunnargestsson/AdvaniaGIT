Function Remove-NAVDeploymentRemoteInstance {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    { 
        $ConfirmedServerInstance = Read-Host "Type name of the server instance to delete"
        if ($ConfirmedServerInstance -ine $SelectedInstance.ServerInstance) { break }
        $SelectedTenant = Get-NAVRemoteInstanceDefaultTenant -SelectedInstance $SelectedInstance
        $RemoteConfig = Get-NAVRemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        $KeyVault = Get-NAVAzureKeyVault -DeploymentName $DeploymentName
        if (!$KeyVault) { break }

        Write-Host "Removing Azure registrations..."
        #Remove DNS Registration
        if ($SelectedTenant.ClickOnceHost -gt "") {
            Remove-NAVAzureDnsZoneRecordSet -DnsHostName $SelectedTenant.ClickOnceHost
        }

        #Remove Password
        if ($SelectedTenant.PasswordId -gt "") {
            Delete-NAVPasswordStateId -PasswordId $SelectedTenant.PasswordId
        }
        
        #Remove AD Application Registration
        Get-AzureRmADServicePrincipal | Where-Object -Property DisplayName -EQ "${DeploymentName}-$($ServerInstance.ServerInstance)" | foreach {            
            Remove-AzureRmKeyVaultAccessPolicy -VaultName $KeyVault.VaultName -ServicePrincipalName $_.ServicePrincipalNames[1]
            Remove-AzureRmADServicePrincipal -ObjectId $_.ObjectId -Force -ErrorAction SilentlyContinue
        }
        Get-AzureRmADApplication | Where-Object -Property DisplayName -EQ "${DeploymentName}-$($ServerInstance.ServerInstance)" | foreach {
            Remove-AzureRmKeyVaultAccessPolicy -VaultName $KeyVault.VaultName -ApplicationId $_.ApplicationId -ObjectId $_.ObjectId 
            Set-AzureRmADApplication -ObjectId $_.ObjectId -AvailableToOtherTenants $false
            Remove-AzureRmADApplication -ObjectId $_.ObjectId -Force -ErrorAction SilentlyContinue
        }

        Foreach ($RemoteComputer in $Remotes.Hosts) {
            Write-Host "Updating $($RemoteComputer.HostName)..."
            $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN         
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*ClickOnce*") {
                # Prepare and Clean Up      
                Remove-NAVRemoteClickOnceSite -Session $Session -SelectedTenant $SelectedTenant  
            }
            if ($Roles -like "*Web*") {
                # Remove old Web Instance
                Remove-NAVRemoteWebInstance -Session $Session -SelectedInstance $SelectedInstance 
            }
            if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {
                Remove-NAVRemoteInstance -Session $Session -ServerInstance $SelectedInstance.ServerInstance 
            }
            Remove-PSSession $Session
        }
    }    
}