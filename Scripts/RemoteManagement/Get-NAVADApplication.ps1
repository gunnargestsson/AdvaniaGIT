Function Get-NAVADApplication {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$ServerInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$IconFilePath
    )
    PROCESS 
    {    
        $DisplayName = "${DeploymentName}-$($ServerInstance.ServerInstance)"
        $Application = Get-AzureRmADApplication | Where-Object -Property DisplayName -eq $DisplayName
        if (!$Application) {
            $IdentifierUri = "http://$(Get-NAVDnsIdentity -SelectedInstance $ServerInstance)/${DisplayName}"
            $ReplyUrls = @("$($ServerInstance.PublicWebBaseUrl)365/WebClient/SignIn.aspx")
            $Application = New-AzureADApplication -DisplayName $DisplayName -IdentifierUris $IdentifierUri -HomePage "$($ServerInstance.PublicWebBaseUrl)365" -ReplyUrls $ReplyUrls -AvailableToOtherTenants $true
            Set-AzureADApplicationLogo -ObjectId $Application.ObjectId -FilePath $IconFilePath
            $RequiredResourceAccess = New-Object -TypeName Microsoft.Open.AzureAD.Model.RequiredResourceAccess
            $ResourceAccess = New-Object -TypeName Microsoft.Open.AzureAD.Model.ResourceAccess
            $ResourceAccess.Id = '311a71cc-e848-46a1-bdf8-97ff7156d8e6'
            $ResourceAccess.Type = 'Scope'
            $RequiredResourceAccess.ResourceAccess = $ResourceAccess
            $RequiredResourceAccess.ResourceAppId = '00000002-0000-0000-c000-000000000000'
            Set-AzureADApplication -ObjectId $Application.ObjectId -RequiredResourceAccess $RequiredResourceAccess
        }
        Return $Application
    }
}