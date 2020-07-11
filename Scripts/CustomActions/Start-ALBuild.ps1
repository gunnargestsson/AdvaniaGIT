Write-Host Build and Update Docker Container
& (Join-path $PSScriptRoot 'Build-NavEnvironment.ps1')

if ($SetupParameters.DownloadDotNetAddins) {
    Write-Host "Dowload DotNet Addins to Server Add-ins folder"
    & (Join-path $PSScriptRoot 'Download-ServerAddins.ps1')
}

if ([int]($SetupParameters.navVersion).split(".")[0] -lt 15) {
    if (![String]::IsNullOrEmpty($SetupParameters.CreateSymbols)) {
        & (Join-path $PSScriptRoot 'Build-NAVSymbolReferences.ps1')
    }

    & (Join-path $PSScriptRoot 'ImportFrom-CALDependencies.ps1')

    Write-Host Initialize Test Company
    & (Join-path $PSScriptRoot 'Initialize-NAVCompany.ps1')
}

Write-Host Import Test Libraries
& (Join-path $PSScriptRoot 'ImportFrom-StandardTestLibrariesToNAV.ps1')

Write-Host Download AL Addin
& (Join-path $PSScriptRoot 'Download-ALAddin.ps1')

Write-Host Download AL Symbols
& (Join-path $PSScriptRoot 'Download-ALSymbols.ps1')

if ([int]($SetupParameters.navVersion).split(".")[0] -ge 15) {
    Write-Host Download AL Dependencies from container
    & (Join-path $PSScriptRoot 'Download-ALDependencies.ps1')
}

if ($SetupParameters.ftpServer -ne "") {
    Write-Host Download AL Dependencies from ftp server
    & (Join-path $PSScriptRoot 'Download-ALDependenciesFromFTPServer.ps1')    
}

if (Test-Path -Path (Join-Path $SetupParameters.repository "Dependencies\*.app")) {
    Write-Host Install AL Dependencies
    if (![string]::IsNullOrEmpty($SetupParameters.dependencyLicenseFilePath)) {
        if (Test-Path $SetupParameters.dependencyLicenseFilePath) {  
            Update-NAVLicense -BranchSettings $BranchSettings -LicenseFilePath $SetupParameters.dependencyLicenseFilePath 
        }
    }
    & (Join-path $PSScriptRoot 'Install-ALDependencies.ps1')
    if (![string]::IsNullOrEmpty($SetupParameters.LicenseFilePath)) {
        if (Test-Path $SetupParameters.LicenseFilePath) {  
            Update-NAVLicense -BranchSettings $BranchSettings -LicenseFilePath $SetupParameters.LicenseFilePath 
        }
    }
}
if ([int]($SetupParameters.navVersion).split(".")[0] -lt 15) {
    if (![String]::IsNullOrEmpty($SetupParameters.restartNAVService)) {
        Write-Host Restart NAV Service
        & (Join-path $PSScriptRoot 'Restart-NAVService.ps1')
    }
}

Write-Host Build AL Solution with Tests
& (Join-path $PSScriptRoot 'Build-ALSolutions.ps1')

Write-Host Install AL Extension
& (Join-path $PSScriptRoot 'Install-ALExtensionsToDocker.ps1')

if ([int]($SetupParameters.navVersion).split(".")[0] -lt 15) {
    Write-Host Execute AL Test Codeunits
    & (Join-path $PSScriptRoot 'Start-ALTestsExecution.ps1')
    Write-Host Save Test Results
    & (Join-path $PSScriptRoot 'Save-TestResults.ps1')
    Write-Host Remove Test Code
} else {
    & (Join-path $PSScriptRoot 'Start-ALTestsInContainer.ps1')
}
if ([int]($SetupParameters.navVersion).split(".")[0] -lt 15) {
    & (Join-path $PSScriptRoot 'Remove-ALTestFolders.ps1')
    Write-Host Clear Previous builds
    & (Join-path $PSScriptRoot 'Clear-ALOutFolder.ps1')
    Write-Host Build AL Solution without Tests
    & (Join-path $PSScriptRoot 'Build-ALSolutions.ps1')
}
Write-Host Copy AL Solution to Artifact folder
& (Join-path $PSScriptRoot 'Copy-ALSolutionToArtifactStagingDirectory.ps1')

if ($SetupParameters.buildRuntimeVersion) {
    if ([int]($SetupParameters.navVersion).split(".")[0] -lt 15) {
        Write-Host Uninstall AL Solutions
        & (Join-path $PSScriptRoot 'Uninstall-ALExtensionsFromDocker.ps1')
        Write-Host Install Clean versions
        & (Join-path $PSScriptRoot 'Install-ALExtensionsToDocker.ps1')
    }
    Write-Host Export Runtime versions
    & (Join-path $PSScriptRoot 'Copy-ALRuntimeToArtifacts.ps1')
}

Write-Host Sign AL Solution in Artifact folder
& (Join-path $PSScriptRoot 'Sign-ArtifactAppPackage.ps1')
