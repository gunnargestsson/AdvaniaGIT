$BaseSetupParameters = Get-BaseBranchSetupParameters -SetupParameters $SetupParameters
$BaseBranchSettings = Get-BranchSettings -SetupParameters $BaseSetupParameters
New-NAVAppJson -SetupParameters $SetupParameters 

$LaunchJsonPath = Join-Path $SetupParameters.VSCodePath ".vscode\launch.json"
if (!(Test-Path -Path (Split-Path (Split-Path $LaunchJsonPath -Parent) -Parent))) {
    New-Item -Path (Split-Path $LaunchJsonPath -Parent) -ItemType Directory | Out-Null
}
if (!(Test-Path -Path (Split-Path $LaunchJsonPath -Parent))) {
    New-Item -Path (Split-Path $LaunchJsonPath -Parent) -ItemType Directory | Out-Null
}

Update-NAVLaunchJson -SetupParameters $SetupParameters -BranchSettings $BaseBranchSettings -LaunchJsonPath $LaunchJsonPath

if (Test-Path -Path $SetupParameters.VSCodeTestPath) {
    $LaunchJsonPath = Join-Path $SetupParameters.VSCodeTestPath ".vscode\launch.json"
    if (!(Test-Path -Path (Split-Path (Split-Path $LaunchJsonPath -Parent) -Parent))) {
        New-Item -Path (Split-Path $LaunchJsonPath -Parent) -ItemType Directory | Out-Null
    }
    if (!(Test-Path -Path (Split-Path $LaunchJsonPath -Parent))) {
        New-Item -Path (Split-Path $LaunchJsonPath -Parent) -ItemType Directory | Out-Null
    }
    Update-NAVLaunchJson -SetupParameters $SetupParameters -BranchSettings $BaseBranchSettings -LaunchJsonPath $LaunchJsonPath
}