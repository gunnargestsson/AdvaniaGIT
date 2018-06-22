& (Join-path $PSScriptRoot Rename-CompanyToCRONUS.ps1)

if ($SetupParameters.testCompanyName) {
    $companyName = $SetupParameters.testCompanyName
} else {
    $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
}

$ExtensionAppJsonFile = Join-Path $SetupParameters.VSCodeTestPath 'app.json'
$ExtensionAppJsonObject = Get-Content -Raw -Path $ExtensionAppJsonFile | ConvertFrom-Json
$CodeunitIdFilter = "BETWEEN $($ExtensionAppJsonObject.idRange.from) AND $($ExtensionAppJsonObject.idRange.to)"

Prepare-NAVTestExecution -BranchSettings $BranchSettings -CompanyName $companyName -CodeunitIdFilter $CodeunitIdFilter
& (Join-path $PSScriptRoot Start-TestClient.ps1)
