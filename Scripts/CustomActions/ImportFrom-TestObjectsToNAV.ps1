Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name
} else {    
    if (Test-Path $SetupParameters.testObjectsPath) {
        foreach ($testObjectFile in (Get-ChildItem -Path $SetupParameters.testObjectsPath)) {
            Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $testObjectFile.FullName -SkipDeleteCheck
        }
    }
    if (Test-Path (Join-Path $env:SystemDrive 'TestToolKit')) {
        foreach ($testObjectFile in (Get-ChildItem -Path (Join-Path $env:SystemDrive 'TestToolKit'))) {
            Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $testObjectFile.FullName -SkipDeleteCheck
        }
    }

}
        

