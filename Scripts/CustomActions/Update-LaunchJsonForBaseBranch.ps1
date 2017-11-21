$BaseSetupParameters = Get-BaseBranchSetupParameters -SetupParameters $SetupParameters
$BaseBranchSettings = Get-BranchSettings -SetupParameters $BaseSetupParameters
New-NAVAppJson -SetupParameters $SetupParameters
Update-NAVLaunchJson -SetupParameters $SetupParameters -BranchSettings $BaseBranchSettings
