Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ($SetupParameters.testCompanyName) {
    $companyName = $SetupParameters.testCompanyName
} else {
    $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
}

Load-InstanceAdminTools -SetupParameters $SetupParameters

Prepare-NAVTestExecution -BranchSettings $BranchSettings -CompanyName $companyName 
$CompanyRegistrationNo = Initialize-NAVTestCompany -SetupParameters $SetupParameters -BranchSettings $BranchSettings -CompanyName $companyName

& (Join-path $PSScriptRoot 'Start-TestClient.ps1')

Set-NAVCompanyInfoRegistrationNo -BranchSettings $BranchSettings -CompanyName $companyName -RegistrationNo $CompanyRegistrationNo

UnLoad-InstanceAdminTools