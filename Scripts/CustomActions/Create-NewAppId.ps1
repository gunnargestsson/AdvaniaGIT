if (!(Test-Path $SetupParameters.SetupPath)) {
    Write-Host "$(Split-Path $SetupParameters.SetupPath -Leaf) in the root of the repository is required!"
    Throw
}

$appId = (New-Guid)
$appName = Split-Path (Get-Item $SetupParameters.SetupPath).Directory -Leaf

$BranchSetup = Get-Content -Path $SetupParameters.SetupPath -Encoding UTF8 | Out-String | ConvertFrom-Json
$BranchSetup.branchId = $appId
$BranchSetup.projectName = $appName
Set-Content -Path $SetupParameters.SetupPath -Encoding UTF8 -Value (ConvertTo-Json -InputObject $BranchSetup)

$appJsonPath = Join-Path $SetupParameters.VSCodePath "app.json"
if (Test-Path $appJsonPath) {
    $appJson = Get-Content -Path $appJsonPath -Encoding UTF8 | Out-String | ConvertFrom-Json
    $appJson.id = $appId
    $appJson.name = $appName
    Set-Content -Path $appJsonPath -Encoding UTF8 -Value (ConvertTo-Json -InputObject $appJson)
}

$appJsonPath = Join-Path $SetupParameters.VSCodeTestPath "app.json"
if (Test-Path $appJsonPath) {
    $appJson = Get-Content -Path $appJsonPath -Encoding UTF8 | Out-String | ConvertFrom-Json
    $appJson.id = (New-Guid)
    $appJson.name = "${appName} Unit Tests"
    $appJson.dependencies[0].appId = $appId
    $appJson.dependencies[0].name = $appName
    Set-Content -Path $appJsonPath -Encoding UTF8 -Value (ConvertTo-Json -InputObject $appJson)
}
