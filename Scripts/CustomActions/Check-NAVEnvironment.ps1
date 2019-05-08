if ($BranchSettings.dockerContainerName -gt "") {
  & (Join-path $PSScriptRoot 'Discover-AllDockerContainers.ps1')
}
Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
