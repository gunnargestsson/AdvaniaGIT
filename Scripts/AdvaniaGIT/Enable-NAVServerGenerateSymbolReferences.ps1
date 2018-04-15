function Enable-NAVServerGenerateSymbolReferences
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    Set-NAVServerConfiguration -ServerInstance $BranchSettings.instanceName -KeyName EnableSymbolLoadingAtServerStartup -KeyValue true
    Set-NAVServerInstance -ServerInstance $BranchSettings.instanceName -Restart
    Get-NAVTenant -ServerInstance $BranchSettings.instanceName | Sync-NAVTenant -Mode Sync -Force
    UnLoad-InstanceAdminTools

}