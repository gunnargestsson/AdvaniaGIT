Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name
} else {    
    Load-IdeTools -SetupParameters $SetupParameters
    $objectTypes = 'Table','Page','Report','Codeunit','Query','XMLport','MenuSuite'
    $jobs = @()
    foreach($objectType in $objectTypes) {
        Write-Host "Starting $objectType compilation..."
        $filter = "Type=$objectType;Version List=<>*Test*"
        $jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter $filter -AsJob -NavServerName localhost -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $SetupParameters.LogPath -SynchronizeSchemaChanges Yes -Recompile    
    }
 
    Receive-Job -Job $jobs -Wait
    foreach($objectType in $objectTypes) {
        Write-Host "Starting $objectType test objects compilation..."
        $filter = "Type=$objectType;Version List=*Test*"
        $jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter $filter -AsJob -NavServerName localhost -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $SetupParameters.LogPath -SynchronizeSchemaChanges Yes -Recompile    
    }
    Receive-Job -Job $jobs -Wait
    UnLoad-IdeTools
}