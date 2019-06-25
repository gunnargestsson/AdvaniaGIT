if ($BranchSettings.dockerContainerId -gt "") {
    if ([Bool](Get-Module NAVContainerHelper)) {
        if ([String]::IsNullOrEmpty($SetupParametesr.testToolkitCountry)) {
            Write-Host Importing Test Toolkit to NAV Container…
            Import-TestToolkitToNavContainer -containerName $BranchSettings.dockerContainerName
        } else {
            Write-Host Importing Test Toolkit for $($SetupParametesr.testToolkitCountry) to NAV Container...
            Import-TestToolkitToNavContainer -containerName $BranchSettings.dockerContainerName -testToolkitCountry $SetupParametesr.testToolkitCountry
        }
    } else {
        Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
    }
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
        

