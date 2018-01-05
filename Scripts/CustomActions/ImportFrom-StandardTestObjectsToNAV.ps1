if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {        
    # Import Standard Test Tool Kit
    if (Test-Path (Join-Path $env:SystemDrive 'TestToolKit')) {
        Load-ModelTools -SetupParameters $SetupParameters
        foreach ($testObjectFile in (Get-ChildItem -Path (Join-Path $env:SystemDrive 'TestToolKit\*.fob'))) {
            Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path $testObjectFile.FullName -ImportAction Overwrite -SynchronizeSchemaChanges Force
        }
        UnLoad-ModelTools
    }    
}
        

