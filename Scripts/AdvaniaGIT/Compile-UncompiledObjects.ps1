function Compile-UncompiledObjects
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$NavServerName = 'localhost'
    )
    Write-Host "Compiling imported objects..."
    Load-IdeTools -SetupParameters $SetupParameters
    Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databaseName -Filter Type=$objectType -AsJob -NavServerName $env:COMPUTERNAME -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $SetupParameters.LogPath -SynchronizeSchemaChanges Force 
    UnLoad-IdeTools
}
