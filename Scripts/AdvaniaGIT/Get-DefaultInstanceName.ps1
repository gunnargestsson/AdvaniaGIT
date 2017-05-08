function Get-DefaultInstanceName
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $DefaultInstance = Get-NAVServerInstance | Where-Object -Property Version -Match $($SetupParameters.mainVersion.Substring(0,2)) | Where-Object -Property Default -EQ True
    Return $($DefaultInstance.ServerInstance)
}