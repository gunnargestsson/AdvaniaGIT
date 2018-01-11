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
if (!(Test-Path (Split-Path -Path $OutFile -Parent))) {
    New-Item -Path (Split-Path -Path $OutFile -Parent) -ItemType Directory | Out-Null
}
Save-NAVTestResultTrx -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName -ResultTableName $ResultTableName -OutFile $OutFile 

if ($SetupParameters.BuildMode) {
    # Created with build
} else {
    # Open results
    & $OutFile
}