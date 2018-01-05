if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}


# Import Custom Test objects
if (Test-Path $SetupParameters.testObjectsPath) {
    Load-ModelTools -SetupParameters $SetupParameters
    foreach ($testObjectFile in (Get-ChildItem -Path (Join-Path $SetupParameters.testObjectsPath '*.txt'))) {
        Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $testObjectFile.FullName -SkipDeleteCheck
    }
    foreach ($testObjectFile in (Get-ChildItem -Path (Join-Path $SetupParameters.testObjectsPath '*.fob'))) {
        Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path $testObjectFile.FullName -ImportAction Overwrite -SynchronizeSchemaChanges Force
    }
    Compile-UncompiledObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    UnLoad-ModelTools
}

        

