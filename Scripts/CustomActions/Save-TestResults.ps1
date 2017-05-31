Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ($SetupParameters.testCompanyName) {
    $companyName = $SetupParameters.testCompanyName
} else {
    $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
}
$ResultTableName = Get-DatabaseTableName -CompanyName $companyName -TableName 'CAL Test Result'
if ($env:bamboo_buildResultKey) {
    $OutFile = Join-Path $env:bamboo_build_working_directory "$($env:bamboo_buildResultKey).trx"
} else {
    $OutFile = Join-Path $LogPath ((Split-Path $SetupParameters.LogPath -Leaf) + ".trx")
}
Save-NAVTestResultTrx -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName -ResultTableName $ResultTableName -OutFile $OutFile 

& $OutFile