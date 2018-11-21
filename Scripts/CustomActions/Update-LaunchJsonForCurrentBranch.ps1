New-NAVAppJson -SetupParameters $SetupParameters

foreach ($ALPath in (Get-ALPaths -SetupParameters $SetupParameters)) {
    $LaunchJsonPath = Join-Path $ALPath.FullName ".vscode\launch.json"
    if (!(Test-Path -Path (Split-Path (Split-Path $LaunchJsonPath -Parent) -Parent))) {
        New-Item -Path (Split-Path $LaunchJsonPath -Parent) -ItemType Directory | Out-Null
    }
    if (!(Test-Path -Path (Split-Path $LaunchJsonPath -Parent))) {
        New-Item -Path (Split-Path $LaunchJsonPath -Parent) -ItemType Directory | Out-Null
    }

    Update-NAVLaunchJson -SetupParameters $SetupParameters -BranchSettings $BranchSettings -LaunchJsonPath $LaunchJsonPath
}
