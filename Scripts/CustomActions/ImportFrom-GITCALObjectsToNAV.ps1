if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

# Import Custom CAL objects
$CALObjectsPath = Join-Path $SetupParameters.repository 'CAL'
if (Test-Path $CALObjectsPath) {
    Load-ModelTools -SetupParameters $SetupParameters
    foreach ($CALObjectFile in (Get-ChildItem -Path (Join-Path $CALObjectsPath '*.txt'))) {
        Write-Host "Importing $($CALObjectFile.Name)..."
        Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $CALObjectFile.FullName -SkipDeleteCheck
    }
    foreach ($CALObjectFile in (Get-ChildItem -Path (Join-Path $CALObjectsPath '*.fob'))) {
        Write-Host "Importing $($CALObjectFile.Name)..."
        Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path $CALObjectFile.FullName -ImportAction Overwrite -SynchronizeSchemaChanges Force
    }
    Compile-UncompiledObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    if ((Get-UncompiledObjectsCount -BranchSettings $BranchSettings) -ne 0) {
        Throw
    }
    & (Join-Path $PSScriptRoot 'Start-ForceSync.ps1')
    UnLoad-ModelTools
}

        

