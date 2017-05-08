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
    Load-InstanceAdminTools -SetupParameters $Setupparameters
    if (!(Get-NAVServerInstance -ServerInstance $BranchSettings.instanceName | Where-Object Where-Object -Property State -EQ Running)) {
        Write-Error "Environment $($BranchSettings.instanceName) is not running!" -ErrorAction Stop
    }
}
