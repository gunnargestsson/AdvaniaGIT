function Compile-UncompiledObjects
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$NavServerName = $env:COMPUTERNAME
    )
    Write-Host "Compiling imported objects..."    
    Load-IdeTools -SetupParameters $SetupParameters
    if (![String]::IsNullOrEmpty($BranchSettings.dockerContainerName)) {
       $NavServerName = $BranchSettings.dockerContainerName
    }

    Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databaseName -Filter Type=$objectType -NavServerName $NavServerName -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $SetupParameters.LogPath -SynchronizeSchemaChanges No    
    UnLoad-IdeTools
}
