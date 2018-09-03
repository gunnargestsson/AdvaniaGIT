if ($BranchSettings.dockerContainerName -gt "") {
  ReRegister-DockerContainer -BranchSettings $BranchSettings
}
Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
