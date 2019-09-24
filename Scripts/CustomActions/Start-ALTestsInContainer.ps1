if ($SetupParameters.testCompanyName) {
    $companyName = $SetupParameters.testCompanyName
} else {
    $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
}

$ResultFile = Join-path $env:ProgramData "NavContainerHelper\Extensions\$($BranchSettings.dockerContainerName)\my\TestResults.xml"
Run-TestsInBCContainer -containerName $BranchSettings.dockerContainerName -XUnitResultFileName $ResultFile
if ($SetupParameters.TestResultsPath) {
    $OutFile = Join-Path $Repository $SetupParameters.TestResultsPath
} else {
    $OutFile = Join-Path $SetupParameters.LogPath "TestResults.xml"
}
if (!(Test-Path (Split-Path -Path $OutFile -Parent))) {
    New-Item -Path (Split-Path -Path $OutFile -Parent) -ItemType Directory | Out-Null
}
Write-Host "Test results saved to ${OutFile}"
Move-Item -Path $ResultFile -Destination $OutFile -Force

