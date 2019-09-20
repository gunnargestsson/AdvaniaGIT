﻿if ($SetupParameters.testCompanyName) {
    $companyName = $SetupParameters.testCompanyName
} else {
    $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
}

$index = 1

foreach ($ALPath in (Get-ALPaths -SetupParameters $SetupParameters)) {
    $ExtensionAppJsonFile = Join-Path $ALPath.FullName 'app.json'
    $ExtensionAppJsonObject = Get-Content -Raw -Path $ExtensionAppJsonFile | ConvertFrom-Json
    if ($ExtensionAppJsonObject.idRange) {
        $CodeunitIdFilter = "BETWEEN $($ExtensionAppJsonObject.idRange.from) AND $($ExtensionAppJsonObject.idRange.to)"
    } elseif ($ExtensionAppJsonObject.idRanges) {
        $CodeunitIdFilter = "BETWEEN $($ExtensionAppJsonObject.idRanges[0].from) AND $($ExtensionAppJsonObject.idRanges[0].to)"
    }

    if ($index -eq 1) {
        Prepare-NAVTestExecution -SetupParameters $SetupParameters -BranchSettings $BranchSettings -CompanyName $companyName -CodeunitIdFilter $CodeunitIdFilter
    } else {
        Prepare-NAVTestExecution -SetupParameters $SetupParameters -BranchSettings $BranchSettings -CompanyName $companyName -CodeunitIdFilter $CodeunitIdFilter -TestExecutionContinuing
    }
    $index += 1
}

& (Join-path $PSScriptRoot Start-TestClient.ps1)
