function Compile-UncompiledObjects
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$Wait,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$NavServerName = 'localhost'
    )
    Write-Host "Compiling imported objects..."
    Load-IdeTools -SetupParameters $SetupParameters
    $objectTypes = 'Table','Page','Report','Codeunit','Query','XMLport','MenuSuite'
    $jobs = @()
    foreach($objectType in $objectTypes)
    {
        Write-Verbose "Starting $objectType compilation..."
        $jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databaseName -Filter Type=$objectType -AsJob -NavServerName $env:COMPUTERNAME -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $LogPath -SynchronizeSchemaChanges Force 
    }
    if ($Wait) { 
        Receive-Job -Job $jobs -Wait
    }
    UnLoad-IdeTools
}
