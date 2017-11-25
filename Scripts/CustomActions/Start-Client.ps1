$ClientSettings = Prepare-NAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings 

$params = @()
$params += @('-settings:"' + $($ClientSettings.Config) + '"')
Write-Host "Running: `"$($ClientSettings.Client)`" $params" -ForegroundColor Green
Start-Process -FilePath $ClientSettings.Client -ArgumentList $params
