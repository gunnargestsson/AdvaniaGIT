Function Set-NAVDeploymentRemoteInstanceADRegistration {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Subscription,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    {          
        $RemoteConfig = Get-NAVRemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        $IconFilePath = Get-NAVClickOnceApplicationIcon -Credential $Credential -DeploymentName $DeploymentName 
        $KeyVault = Get-NAVAzureKeyVault -DeploymentName $DeploymentName
        if (!$KeyVault) { break }

        Write-Host "Updating Instance for $DeploymentName..."
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {
                Write-Host "Updating $($RemoteComputer.HostName)..."
                $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN
                $ServerInstances = Get-NAVRemoteInstances -Session $Session 
                foreach ($ServerInstance in $ServerInstances) {                    
                    $CertValue = Get-NAVServiceCertificateValue -Session $Session -ServerInstance $ServerInstance 
                    $KeyVaultKey = Get-NAVAzureKeyVaultKey -KeyVault $KeyVault -ServerInstanceName $ServerInstance.ServerInstance
                    $Application = Get-NAVADApplication -DeploymentName $DeploymentName -ServerInstance $ServerInstance -IconFilePath $IconFilePath -CertValue $CertValue
                    $ServicePrincipal = Get-NAVADServicePrincipal -ADApplication $Application                   
                    Set-AzureRmKeyVaultAccessPolicy -VaultName $KeyVault.VaultName -ServicePrincipalName $ServicePrincipal.ServicePrincipalNames[1] -PermissionsToKeys encrypt,decrypt,get
                    Set-AzureRmKeyVaultAccessPolicy -VaultName $KeyVault.VaultName -ApplicationId $Application.ApplicationId -ObjectId $Application.ObjectId -PermissionsToKeys encrypt,decrypt,get
                    $ServerInstance = Combine-Settings $ServerInstance $KeyVault -Prefix KeyVault
                    $ServerInstance = Combine-Settings $ServerInstance $KeyVaultKey -Prefix KeyVaultKey
                    $ServerInstance = Combine-Settings $ServerInstance $ServicePrincipal -Prefix ServicePrincipal
                    $ServerInstance = Combine-Settings $ServerInstance $Application -Prefix ADApplication
                    $ServerInstance | Add-Member -MemberType NoteProperty -Name ADApplicationFederationMetadataLocation -Value "https://login.windows.net/$($Subscription.Account.Id.Split("@").GetValue(1))/federationmetadata/2007-06/federationmetadata.xml"
                    Set-NAVRemoteInstanceADRegistration -Session $Session -ServerInstance $ServerInstance -RestartServerInstance
                }
                
                Remove-PSSession -Session $Session 
            }
        }
        Remove-Item -Path (Split-Path $IconFilePath -Parent) -Recurse -Force -ErrorAction SilentlyContinue
        $anyKey = Read-Host "Press enter to continue..."
    }
}