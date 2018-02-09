Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
$ClientSettings = Prepare-NAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings 

$params = @()
$params += @('-settings:"' + $($ClientSettings.Config) + '"')
$params += " `"DynamicsNAV://///debug`""
Write-Host "Running: `"$($ClientSettings.Client)`" $params" -ForegroundColor Green
Start-Process -FilePath $ClientSettings.Client -ArgumentList $params
