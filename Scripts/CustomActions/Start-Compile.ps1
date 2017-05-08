Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
Load-IdeTools -SetupParameters $SetupParameters
$objectTypes = 'Table','Page','Report','Codeunit','Query','XMLport','MenuSuite'
$jobs = @()
foreach($objectType in $objectTypes) {
    Write-Host "Starting $objectType compilation..."
    $jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter Type=$objectType -AsJob -NavServerName localhost -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $LogPath -SynchronizeSchemaChanges Yes -Recompile    
}
 
Receive-Job -Job $jobs -Wait
UnLoad-IdeTools