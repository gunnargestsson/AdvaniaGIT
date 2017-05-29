Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ($SetupParameters.testCompanyName) {
    $companyName = $SetupParameters.testCompanyName
} else {
    $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
}
$ResultTableName = Get-TestResultTableName -CompanyName $companyName
$OutFile = Join-Path $LogPath ((Split-Path $LogPath -Leaf) + ".trx")
Save-NAVTestResultTrx -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName -ResultTableName $ResultTableName -OutFile $OutFile 

& $OutFile