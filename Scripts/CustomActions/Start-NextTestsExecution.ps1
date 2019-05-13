Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ($SetupParameters.testCompanyName) {
    $companyName = $SetupParameters.testCompanyName
} else {
    $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
}

& (Join-Path $PSScriptRoot Add-NAVWindowsUser.ps1) 
Prepare-NAVTestExecution -SetupParameters $SetupParameters -BranchSettings $BranchSettings -CompanyName $companyName -CodeunitIdFilter $SetupParameters.codeunitIdFilter -TestExecutionContinuing
& (Join-Path $PSScriptRoot Prepare-NAVUnitTest.ps1) 

if ([bool]($SetupParameters.PSObject.Properties.name -match "testExecution") -and $SetupParameters.testExecution -ieq "Background") {
    & (Join-Path $PSScriptRoot Start-TestCodeunit.ps1)
} else {
    & (Join-path $PSScriptRoot Start-TestClient.ps1)
}
