$BaseSetupParameters = Get-BaseBranchSetupParameters -SetupParameters $SetupParameters
$BaseBranchSettings = Get-BranchSettings -SetupParameters $BaseSetupParameters
New-NAVAppJson -SetupParameters $SetupParameters 

$LaunchJsonPath = Join-Path $SetupParameters.VSCodePath ".vscode\launch.json"
if (!(Test-Path -Path (Split-Path $LaunchJsonPath -Parent))) {
    New-Item -Path (Split-Path $LaunchJsonPath -Parent) -ItemType Directory | Out-Null
}

Update-NAVLaunchJson -SetupParameters $SetupParameters -BranchSettings $BaseBranchSettings -LaunchJsonPath $LaunchJsonPath

$LaunchJsonPath = Join-Path "$($SetupParameters.VSCodePath)$(Split-Path $SetupParameters.testObjectsPath -Leaf)" ".vscode\launch.json"
Update-NAVLaunchJson -SetupParameters $SetupParameters -BranchSettings $BaseBranchSettings -LaunchJsonPath $LaunchJsonPath
