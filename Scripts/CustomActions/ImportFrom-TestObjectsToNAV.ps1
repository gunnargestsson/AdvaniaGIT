Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-ModelTools -SetupParameters $SetupParameters
    # Import Standard Test Tool Kit
    if (Test-Path (Join-Path $env:SystemDrive 'TestToolKit')) {
        foreach ($testObjectFile in (Get-ChildItem -Path (Join-Path $env:SystemDrive 'TestToolKit\*.txt'))) {
            Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $testObjectFile.FullName -SkipDeleteCheck
        }
        foreach ($testObjectFile in (Get-ChildItem -Path (Join-Path $env:SystemDrive 'TestToolKit\*.fob'))) {
            Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path $testObjectFile.FullName -ImportAction Overwrite -SynchronizeSchemaChanges Force
        }
    }
    # Import Custom Test objects
    if (Test-Path $SetupParameters.testObjectsPath) {
        foreach ($testObjectFile in (Get-ChildItem -Path (Join-Path $SetupParameters.testObjectsPath '*.txt'))) {
            Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $testObjectFile.FullName -SkipDeleteCheck
        }
        foreach ($testObjectFile in (Get-ChildItem -Path (Join-Path $SetupParameters.testObjectsPath '*.fob'))) {
            Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path $testObjectFile.FullName -ImportAction Overwrite -SynchronizeSchemaChanges Force
        }
    }
    UnLoad-ModelTools
}
        

