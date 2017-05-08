Load-InstanceAdminTools -SetupParameters $SetupParameters
Load-AppsManagementTools  -SetupParameters $SetupParameters
$DefaultInstance = Get-DefaultInstanceName -SetupParameters $SetupParameters -BranchSettings $BranchSettings

$appPackageFileName = (Join-Path $ExtensionPath 'AppPackage.navx')
Copy-Item -Path $appPackageFileName -Destination $LogPath
$installationPackage = (Join-Path $LogPath 'AppPackage.navx')

Write-Host "$($SetupParameters.appName) is being published to server instance $DefaultInstance"

if (Test-Path $SetupParameters.CodeSigningCertificate) {
  Write-Host "Signing NAVX package..."
  & $($SetupParameters.SigToolExecutable) sign /t http://timestamp.verisign.com/scripts/timestamp.dll /f $($SetupParameters.CodeSigningCertificate) /p $($SetupParameters.CodeSigningCertificatePassword) $installationPackage
  Publish-NAVApp `
    -ServerInstance $DefaultInstance `
    -Path $installationPackage `
}
else
{
  Publish-NAVApp `
    -ServerInstance $DefaultInstance `
    -Path $installationPackage `
    -SkipVerification
}
Write-Host $SetupParameters.appName "published to server " $DefaultInstance
UnLoad-AppsManagementTools
UnLoad-InstanceAdminTools