$BaseSetupParameters = Get-BaseBranchSetupParameters -SetupParameters $SetupParameters
$BaseBranchSettings = Get-BranchSettings -SetupParameters $BaseSetupParameters    

$ClientSettings = Prepare-NAVClient -SetupParameters $BaseSetupParameters -BranchSettings $BaseBranchSettings 

$params = @()
$params += @('-settings:"' + $($ClientSettings.Config) + '"')
Write-Host "Running: `"$($ClientSettings.Client)`" $params" -ForegroundColor Green
Start-Process -FilePath $ClientSettings.Client -ArgumentList $params
