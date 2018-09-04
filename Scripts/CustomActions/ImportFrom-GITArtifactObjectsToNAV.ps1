if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

# Import Artifact objects
$ArtifactObjectPath = Join-Path $SetupParameters.Repository "Artifacts"
if (Test-Path $ArtifactObjectPath) {
    Load-ModelTools -SetupParameters $SetupParameters
    foreach ($testObjectFile in (Get-ChildItem -Path (Join-Path $ArtifactObjectPath '*.txt'))) {
        Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $testObjectFile.FullName -SkipDeleteCheck
    }
    foreach ($testObjectFile in (Get-ChildItem -Path (Join-Path $ArtifactObjectPath '*.fob'))) {
        Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path $testObjectFile.FullName -ImportAction Overwrite -SynchronizeSchemaChanges Force
    }
    Compile-UncompiledObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    & (Join-Path $PSScriptRoot 'Start-ForceSync.ps1')
    UnLoad-ModelTools
}

        

