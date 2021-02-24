if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}


# Import Custom Test objects
if (Test-Path $SetupParameters.testObjectsPath) {
    Load-ModelTools -SetupParameters $SetupParameters

    $CombinedTestFileName = $SetupParameters.workFolder + "\TestObjects.txt"
        Write-Host("CombinedFileName value: $($CombinedTestFileName)")
        New-Item -ItemType file $CombinedTestFileName –force

    foreach ($testObjectFile in (Get-ChildItem -Path (Join-Path $SetupParameters.testObjectsPath '*.txt'))) {
        #Write-Host "Importing $($testObjectFile.Name)..."
        #Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $testObjectFile.FullName -SkipDeleteCheck
        ##Write-Verbose -Message "Adding FileName.FileName :. $($testObjectFile.FileName.FileName)"
        Write-Verbose -Message "Adding Name :  $($testObjectFile.Name)"
        Get-Content $($testObjectFile.FullName) | Add-Content $CombinedTestFileName
    }
    
    Write-Host "Importing $($CombinedTestFileName)..."
    Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $CombinedTestFileName -SkipDeleteCheck
        
    foreach ($testObjectFile in (Get-ChildItem -Path (Join-Path $SetupParameters.testObjectsPath '*.fob'))) {
        Write-Host "Importing $($testObjectFile.Name)..."
        Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path $testObjectFile.FullName -ImportAction Overwrite -SynchronizeSchemaChanges Force
    }
    Compile-UncompiledObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    if ((Get-UncompiledObjectsCount -BranchSettings $BranchSettings) -ne 0) {
        Throw
    }
    & (Join-Path $PSScriptRoot 'Start-ForceSync.ps1')
    UnLoad-ModelTools
}