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
    if (!(Get-Service -Name "MicrosoftDynamicsNavServer`$$($BranchSettings.instanceName)" | Where-Object -Property Status -EQ Running)) {
        Write-Error "Environment $($BranchSettings.instanceName) is not running!" -ErrorAction Stop
    }
}
