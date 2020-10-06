if ($SetupParameters.testCompanyName) {
    $companyName = $SetupParameters.testCompanyName
} else {
    $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
}

$ResultFile = Join-path $env:ProgramData "$SetupParameters.containerHelperModuleName\Extensions\$($BranchSettings.dockerContainerName)\my\TestResults.xml"
foreach ($ALPath in (Get-ALPaths -SetupParameters $SetupParameters)) {
    $ALProjectFolder = $ALPath.FullName
    $ExtensionAppJsonFile = Join-Path $ALProjectFolder 'app.json'
    $ExtensionAppJsonObject = Get-Content -Raw -Path $ExtensionAppJsonFile | ConvertFrom-Json
    if (Test-Path -Path $ResultFile) {
        Run-TestsInBCContainer -containerName $BranchSettings.dockerContainerName -XUnitResultFileName $ResultFile -extensionId $ExtensionAppJsonObject.id -AppendToXUnitResultFile
    } else {
        Run-TestsInBCContainer -containerName $BranchSettings.dockerContainerName -XUnitResultFileName $ResultFile -extensionId $ExtensionAppJsonObject.id
    }
}
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

