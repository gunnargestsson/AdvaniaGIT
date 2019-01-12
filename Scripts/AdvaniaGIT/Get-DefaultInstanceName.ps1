function Get-DefaultInstanceName
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $DefaultInstance = Get-NAVServerInstance | -Match ($SetupParameters.navVersion.Substring(0,1 + $SetupParameters.navVersion.IndexOf(".")) + "\d.\d+.0") | Select-Object -First 1
    Return $($DefaultInstance.ServerInstance)
}