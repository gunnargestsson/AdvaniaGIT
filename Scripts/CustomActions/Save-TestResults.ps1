Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ($SetupParameters.testCompanyName) {
    $companyName = $SetupParameters.testCompanyName
} else {
    $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
}
$ResultTableName = Get-DatabaseTableName -CompanyName $companyName -TableName 'CAL Test Result'
if ($SetupParameters.TestResultsPath) {
    $OutFile = Join-Path $Repository $SetupParameters.TestResultsPath
} else {
    $OutFile = Join-Path $LogPath ((Split-Path $SetupParameters.LogPath -Leaf) + ".trx")
}
Save-NAVTestResultTrx -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName -ResultTableName $ResultTableName -OutFile $OutFile 

& $OutFile