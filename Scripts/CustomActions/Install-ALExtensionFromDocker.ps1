if ($BranchSettings.dockerContainerName -gt "") {
    Copy-DockerALExtension -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    Install-ALforVSCode -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}