Function Get-NAVRemoteInstanceHealthCheck {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )
    PROCESS 
    {
        try {
            $result = Invoke-WebRequest -Uri "$($SelectedInstance.PublicWebBaseUrl)/WebClient/Health/System" -UseBasicParsing -TimeoutSec 10
            if ($result.StatusCode -eq 200 -and ((ConvertFrom-Json $result.Content).result)) {
                # Web Client Health Check Endpoint will test Web Client, Service Tier and Database Connection
                return "Healthy"
            }
        } catch {
            return "No Connection"
        }
        return "Not Healthy"
    }    
}


