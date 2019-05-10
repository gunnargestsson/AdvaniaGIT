Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
  
if ($SetupParameters.patchNoFunction -ne "") {
    Invoke-Expression $($SetupParameters.patchNoFunction)
}

if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    $NavServerName = $BranchSettings.dockerContainerName
} else {
    $NavServerName = localhost
}

Load-IdeTools -SetupParameters $SetupParameters
$objectType = 'Query'
$jobs = @()

    Write-Host "Starting $objectType compilation..."
    $filter = "Type=$objectType;Version List=<>*Test*"
    $LogPath = Join-Path $SetupParameters.LogPath $ObjectType
    New-Item -Path $LogPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    if ([int]$SetupParameters.navVersion.Split(".")[0] -ge 11) {
    	if ($SetupParameters.SqlUsername) {
    		if ($SetupParameters.SqlUsername) {
        	$jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter $filter -AsJob -NavServerName $NavServerName -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $LogPath -SynchronizeSchemaChanges Yes -Recompile -GenerateSymbolReference -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
       	} else {
       		$jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter $filter -AsJob -NavServerName $NavServerName -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $LogPath -SynchronizeSchemaChanges Yes -Recompile -GenerateSymbolReference
       	}
      } else {
      	if ($SetupParameters.SqlUsername) {
      		$jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter $filter -AsJob -NavServerName $NavServerName -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $LogPath -SynchronizeSchemaChanges Yes -Recompile -GenerateSymbolReference -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
      	} else {
      		$jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter $filter -AsJob -NavServerName $NavServerName -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $LogPath -SynchronizeSchemaChanges Yes -Recompile -GenerateSymbolReference
      	}
      }
    } else {
    	if ($SetupParameters.SqlUsername) {
    		if ($SetupParameters.SqlUsername) {
        	$jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter $filter -AsJob -NavServerName $NavServerName -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $LogPath -SynchronizeSchemaChanges Yes -Recompile -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
        } else {
        	$jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter $filter -AsJob -NavServerName $NavServerName -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $LogPath -SynchronizeSchemaChanges Yes -Recompile
        }
      } else {
      	if ($SetupParameters.SqlUsername) {
      		$jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter $filter -AsJob -NavServerName $NavServerName -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $LogPath -SynchronizeSchemaChanges Yes -Recompile -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
      	} else {
      		$jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter $filter -AsJob -NavServerName $NavServerName -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $LogPath -SynchronizeSchemaChanges Yes -Recompile
      	}
      }
    }
    Receive-Job -Job $jobs -Wait     

UnLoad-IdeTools
