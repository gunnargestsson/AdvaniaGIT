Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ($SetupParameters.testCompanyName) {
    $companyName = $SetupParameters.testCompanyName
} else {
    $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
}

$CompanyRegistrationNo = Initialize-NAVTestCompanyRegistrationNo -BranchSettings $BranchSettings -CompanyName $companyName
Prepare-NAVTestExecution -BranchSettings $BranchSettings -CompanyName $companyName -ForModifiedObjects
& (Join-Path $PSScriptRoot Prepare-NAVUnitTest.ps1) 
& (Join-path $PSScriptRoot Start-TestClient.ps1)
Set-NAVCompanyInfoRegistrationNo -BranchSettings $BranchSettings -CompanyName $companyName -RegistrationNo $CompanyRegistrationNo
