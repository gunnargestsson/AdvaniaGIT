if (!(Test-Path $SetupParameters.SetupPath)) {
    Write-Host "$(Split-Path $SetupParameters.SetupPath -Leaf) in the root of the repository is required!"
    Throw
}

$appId = (New-Guid)
$appName = Split-Path (Get-Item $SetupParameters.SetupPath).Directory -Leaf

$BranchSetup = Get-Content -Path $SetupParameters.SetupPath -Encoding UTF8 | Out-String | ConvertFrom-Json
$BranchSetup.branchId = $appId
if ([bool]($BranchSetup.PSObject.Properties.name -match "ALProjectList")) {
    if ($BranchSetup.ALProjectList -eq "HelloWorld") {
        $BranchSetup.ALProjectList = $appName
    }
} else {
    $BranchSetup.projectName = $appName
}

Set-Content -Path $SetupParameters.SetupPath -Encoding UTF8 -Value (ConvertTo-Json -InputObject $BranchSetup)

if ([String]::IsNullOrEmpty($SetupParameters.ALProjectList)) {
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
        $appJson.name = "${appName}.Test"
        $appJson.dependencies[0].appId = $appId
        $appJson.dependencies[0].name = $appName
        Set-Content -Path $appJsonPath -Encoding UTF8 -Value (ConvertTo-Json -InputObject $appJson)
    }
} elseif ($SetupParameters.ALProjectList -eq "HelloWorld") {
    $appJsonPath = Join-Path $SetupParameters.Repository "HelloWorld\app.json"
    if (Test-Path $appJsonPath) {
        $appJson = Get-Content -Path $appJsonPath -Encoding UTF8 | Out-String | ConvertFrom-Json
        $appJson.id = $appId
        $appJson.name = $appName
        Set-Content -Path $appJsonPath -Encoding UTF8 -Value (ConvertTo-Json -InputObject $appJson)
        Move-Item -Path (Join-Path $SetupParameters.Repository "HelloWorld") -Destination (Join-Path $SetupParameters.Repository $appName)
    }
}  else {
    foreach ($ALPath in (Get-ALPaths -SetupParameters $SetupParameters)) {
        $appJsonPath = Join-Path $ALPath.FullName "app.json"
        if (Test-Path $appJsonPath) {
            $appJson = Get-Content -Path $appJsonPath -Encoding UTF8 | Out-String | ConvertFrom-Json
            if (![bool]($appJson.PSObject.Properties.name -match "id")) {
                $appJson | Add-Member -MemberType NoteProperty -Name id -Value (New-Guid)
                Set-Content -Path $appJsonPath -Encoding UTF8 -Value (ConvertTo-Json -InputObject $appJson)
            }
        }
    }
} 