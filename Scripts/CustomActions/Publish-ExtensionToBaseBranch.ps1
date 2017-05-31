Load-AppsManagementTools  -SetupParameters $SetupParameters
$BaseSetupParameters = Get-BaseBranchSetupParameters -SetupParameters $SetupParameters
$BaseBranchSettings = Get-BranchSettings -SetupParameters $BaseSetupParameters
Check-NAVServiceRunning -SetupParameters $BaseSetupParameters -BranchSettings $BaseBranchSettings

$appPackageFileName = (Join-Path $SetupParameters.ExtensionPath 'AppPackage.navx')
Copy-Item -Path $appPackageFileName -Destination $SetupParameters.LogPath
$installationPackage = (Join-Path $SetupParameters.LogPath 'AppPackage.navx')

Write-Host "$($SetupParameters.appName) is being published to server instance $($BaseBranchSettings.instanceName)"

if (Test-Path $SetupParameters.CodeSigningCertificate) {
  Write-Host "Signing NAVX package..."
  & $($SetupParameters.SigToolExecutable) sign /t http://timestamp.verisign.com/scripts/timestamp.dll /f $($SetupParameters.CodeSigningCertificate) /p $($SetupParameters.CodeSigningCertificatePassword) $installationPackage
  Publish-NAVApp `
    -ServerInstance $BaseBranchSettings.instanceName `
    -Path $installationPackage `
}
else
{
  Publish-NAVApp `
    -ServerInstance $BaseBranchSettings.instanceName `
    -Path $installationPackage `
    -SkipVerification
}
Write-Host "$($SetupParameters.appName) published to server $($BaseBranchSettings.instanceName)"
UnLoad-AppsManagementTools
