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
        $IdentifierUri = "http://localhost/$DisplayName"
        $Application = Get-AzureRmADApplication | Where-Object -Property DisplayName -eq $DisplayName
        if (!$Application) {
            $Application = New-AzureADApplication -DisplayName $DisplayName -IdentifierUris $IdentifierUri -HomePage $ServerInstance.PublicWebBaseUrl -ReplyUrls @($ServerInstance.PublicWebBaseUrl)
            Set-AzureADApplicationLogo -ObjectId $Application.ObjectId -FilePath $IconFilePath
        }
        Return $Application
    }
}