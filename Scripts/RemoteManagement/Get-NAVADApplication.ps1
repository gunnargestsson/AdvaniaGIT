Function Get-NAVADApplication {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$ServerInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$IconFilePath,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$CertValue,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$ReplaceApplication
    )
    PROCESS 
    {    
        $DisplayName = "${DeploymentName}-$($ServerInstance.ServerInstance)"
        $Application = Get-AzureRmADApplication -DisplayNameStartWith $DisplayName        
        if (!$Application) {
            $ReplaceApplication = $true
        } else {
            if ($ReplaceApplication) {
                $ObjectId = $Application.ObjectId
                Set-AzureRmADApplication -ObjectId $ObjectId -AvailableToOtherTenants $False
                Remove-AzureRmADApplication -ObjectId $ObjectId -Force
            }
        }
        if ($ReplaceApplication) {
            $x509 = [System.Security.Cryptography.X509Certificates.X509Certificate2]([System.Convert]::FromBase64String($CertValue))           
            $IdentifierUri = "http://$(Get-NAVDnsIdentity -SelectedInstance $ServerInstance)/${DisplayName}"
            if ([int]($ServerInstance.Version).split('.')[0] -ge 13) {
                $ReplyUrls = @("$($ServerInstance.PublicWebBaseUrl)365/SignIn")
            } else {
                $ReplyUrls = @("$($ServerInstance.PublicWebBaseUrl)365/WebClient/SignIn.aspx")
            }
            $Application = New-AzureRmADApplication -DisplayName $DisplayName -HomePage "$($ServerInstance.PublicWebBaseUrl)365" -IdentifierUris $IdentifierUri -ReplyUrls $ReplyUrls -CertValue $CertValue -StartDate $x509.NotBefore -EndDate $x509.NotAfter 
            $ObjectId = $Application.ObjectId
            Set-AzureRmADApplication -ObjectId $ObjectId -AvailableToOtherTenants $True
            Set-AzureADApplicationLogo -ObjectId $ObjectId -FilePath $IconFilePath -ErrorAction SilentlyContinue
            $RequiredResourceAccess = New-Object -TypeName Microsoft.Open.AzureAD.Model.RequiredResourceAccess
            $ResourceAccess = New-Object -TypeName Microsoft.Open.AzureAD.Model.ResourceAccess
            $ResourceAccess.Id = '311a71cc-e848-46a1-bdf8-97ff7156d8e6'
            $ResourceAccess.Type = 'Scope'
            $RequiredResourceAccess.ResourceAccess = $ResourceAccess
            $RequiredResourceAccess.ResourceAppId = '00000002-0000-0000-c000-000000000000'
            Set-AzureADApplication -ObjectId $ObjectId -RequiredResourceAccess $RequiredResourceAccess
            $Application = Get-AzureRmADApplication -DisplayNameStartWith $DisplayName
        } else {
            $x509 = [System.Security.Cryptography.X509Certificates.X509Certificate2]([System.Convert]::FromBase64String($CertValue))
            Get-AzureRmADAppCredential -ObjectId $Application.ObjectId | Remove-AzureRmADAppCredential -ObjectId $Application.ObjectId -Force | Out-Null
            $newCredential = New-AzureRmADAppCredential -ObjectId $Application.ObjectId -CertValue $CertValue -StartDate $x509.NotBefore -EndDate $x509.NotAfter
        }
        Return $Application
    }
}