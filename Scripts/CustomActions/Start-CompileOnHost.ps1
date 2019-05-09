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
$ErrorObjects = @()
$objectTypes = 'Table','Page','Report','Codeunit','Query','XMLport','MenuSuite'
$jobs = @()
foreach($objectType in $objectTypes) {
    Write-Host "Starting $objectType compilation..."
    $filter = "Type=$objectType;Version List=<>*Test*"
    $LogPath = Join-Path $SetupParameters.LogPath $ObjectType
    New-Item -Path $LogPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    if ([int]$SetupParameters.navVersion.Split(".")[0] -ge 11) {
        $jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter $filter -AsJob -NavServerName $NavServerName -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $LogPath -SynchronizeSchemaChanges Yes -Recompile -GenerateSymbolReference -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
    } else {
        $jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter $filter -AsJob -NavServerName $NavServerName -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $LogPath -SynchronizeSchemaChanges Yes -Recompile -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword    
    }
    Receive-Job -Job $jobs -Wait     
}
    
foreach($objectType in $objectTypes) {
    Write-Host "Starting $objectType test objects compilation..."
    $filter = "Type=$objectType;Version List=*Test*"
    if ([int]$SetupParameters.navVersion.Split(".")[0] -ge 11) {
        $jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter $filter -AsJob -NavServerName $NavServerName -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $LogPath -SynchronizeSchemaChanges Yes -Recompile -GenerateSymbolReference -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
    } else {
        $jobs += Compile-NAVApplicationObject -DatabaseServer (Get-DatabaseServer -BranchSettings $BranchSettings) -DatabaseName $BranchSettings.databasename -Filter $filter -AsJob -NavServerName $NavServerName -NavServerInstance $BranchSettings.instanceName -NavServerManagementPort $BranchSettings.managementServicesPort -LogPath $LogPath -SynchronizeSchemaChanges Yes -Recompile -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword    
    }
    Receive-Job -Job $jobs -Wait
}

foreach ($job in $jobs.ChildJobs) {
    [string]$Error = $job.Error
    foreach ($line in $Error.Split("`n")) {
        $pos = $line.IndexOf("Object:")
        if ($pos -gt 0) {                
            $ObjInfo = $line.Substring($pos + 8, $line.Length - $pos - 8).Split(" ")
            $Object = New-Object -TypeName PSObject                
            $Object | Add-Member -MemberType NoteProperty -Name Type -Value $ObjInfo[0]
            $Object | Add-Member -MemberType NoteProperty -Name Id -Value $ObjInfo[1]
            $Object | Add-Member -MemberType NoteProperty -Name Name -Value $ObjInfo[2]
            if ([bool]($SetupParameters.PSObject.Properties.name -match "ignoreCompileErrors")) {
                $skipObject = $SetupParameters.ignoreCompileErrors | Where-Object -Property Id -EQ $Object.Id | Where-Object -Property Type -EQ $Object.Type
                if ($skipObject -eq $null) {
                    $ErrorObjects += $Object
                }
            } else {
                $ErrorObjects += $Object                                
            }
        }
    }
}
    
if ($ErrorObjects.Length -gt 0) {
    Write-Host -ForegroundColor Red "Compilation Errors in objects:"
    $ErrorObjects | Format-Table -AutoSize 
    throw 
}

UnLoad-IdeTools
