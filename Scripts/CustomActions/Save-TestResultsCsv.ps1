Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ($SetupParameters.testCompanyName) {
    $companyName = $SetupParameters.testCompanyName
} else {
    $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
}
$ResultTableName = Get-DatabaseTableName -CompanyName $companyName -TableName 'CAL Test Result'
$OutFile = Join-Path $LogPath ((Split-Path $SetupParameters.LogPath -Leaf) + ".csv")
Save-NAVTestResultCsv -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName -ResultTableName $ResultTableName -OutFile $OutFile 

& $OutFile