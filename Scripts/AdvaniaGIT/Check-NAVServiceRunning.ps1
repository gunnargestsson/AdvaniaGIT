Function Check-NAVServiceRunning
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    if ($BranchSettings.instanceName -eq "") {
        Write-Error "Environment has not been created!" -ErrorAction Stop
    }
    if ($BranchSettings.dockerContainerId -eq "") {
        if (!(Get-Service -ComputerName $BranchSettings.instanceServer -Name "MicrosoftDynamicsNavServer`$$($BranchSettings.instanceName)" | Where-Object -Property Status -EQ Running)) {
            Write-Error "Environment $($BranchSettings.instanceName) is not running!" -ErrorAction Stop
        }
    } else {
        ReStart-DockerContainer -BranchSettings $BranchSettings
        $result = Invoke-WebRequest -Uri "$($BranchSettings.dockerContainerName)/NAV/WebClient/Health/System" -UseBasicParsing -TimeoutSec 10
        if ($result.StatusCode -eq 200 -and ((ConvertFrom-Json $result.Content).result)) {
            # Web Client Health Check Endpoint will test Web Client, Service Tier and Database Connection
            Write-Host "Docker Image on $($BranchSettings.dockerContainerName) is responding correctly..."
        } else {
            Write-Error "Docker Image on $($BranchSettings.dockerContainerName) is not responding!" -ErrorAction Stop
        }
    }
}
