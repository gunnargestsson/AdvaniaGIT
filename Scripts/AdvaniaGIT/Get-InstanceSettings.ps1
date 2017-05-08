function Get-InstanceSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    
    Load-InstanceAdminTools -setupParameters $SetupParameters
    $instanceSettings = Get-NAVServerConfiguration2 -ServerInstance $BranchSettings.instanceName 
    Return $instanceSettings
}