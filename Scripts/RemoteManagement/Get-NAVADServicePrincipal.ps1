Function Get-NAVADServicePrincipal {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$ADApplication
    )
    PROCESS 
    {   
        $ServicePrincipal = Get-AzureRmADServicePrincipal | Where-Object -Property DisplayName -EQ $ADApplication.DisplayName
        if (!$ServicePrincipal) {
            $ServicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $ADApplication.ApplicationId
        }
        Return $ServicePrincipal
    }
}