$ClientSettings = Prepare-NAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings 

$params = @()
$params += @('-settings:"' + $($ClientSettings.Config) + '"')

if ($SetupParameters.selectClientRoleCenter) {
    $roleCenter = Get-NAVRoleCenter -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    $params += @('-profile:"' + ${roleCenter} +'"')
}

Write-Host "Running: `"$($ClientSettings.Client)`" $params" -ForegroundColor Green
Start-Process -FilePath $ClientSettings.Client -ArgumentList $params
