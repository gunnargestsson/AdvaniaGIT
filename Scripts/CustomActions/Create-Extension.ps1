Check-GitNotUnattached

Load-AppsTools -SetupParameters $SetupParameters
if (Test-Path $ExtensionPath) 
{
  Remove-Item -Path $ExtensionPath -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -Path $ExtensionPath -ItemType Directory | Out-Null

$appManifastFilePath = (Join-Path $ExtensionPath "AppManifest.xml")
$appPackageFileName = (Join-Path $ExtensionPath 'AppPackage.navx')

$params = @{ 
  Id = $SetupParameters.appId
  Name = $SetupParameters.appManifestName 
  Publisher = $SetupParameters.appPublisher 
  Version = $SetupParameters.appVersion 
  Description = $SetupParameters.appManifestDescription }
if ($SetupParameters.appBriefDescription -ne "") { $params.Brief = $SetupParameters.appBriefDescription }
if ($SetupParameters.appCompatibilityId -ne "") { $params.CompatibilityId = $SetupParameters.appCompatibilityId }
if ($SetupParameters.appPrivacyStatement -ne "") { $params.PrivacyStatement = $SetupParameters.appPrivacyStatement }
if ($SetupParameters.appEula -ne "") { $params.Eula = $SetupParameters.appEula }
if ($SetupParameters.appHelp -ne "") { $params.Help = $SetupParameters.appHelp }
if ($SetupParameters.appUrl -ne "") { $params.Url = $SetupParameters.appUrl }
if ($SetupParameters.appPrerequisities -ne "") { $params.Prerequisites = $SetupParameters.appPrerequisities }
if ($SetupParameters.appDependencies -ne "") { $params.Dependencies = $SetupParameters.appDependencies }

New-NAVAppManifest @params | New-NAVAppManifestFile -Path $appManifastFilePath -Force

$ResourceFolder = (Join-Path $WorkFolder 'Resources')
Remove-Item -Path $ResourceFolder -Recurse -Force -ErrorAction SilentlyContinue
New-Item $ResourceFolder -ItemType Directory | Out-Null
if (Test-Path $DeltasPath) {
  Write-Host "Copying Deltas..."
  Copy-Item -Path (Join-Path $DeltasPath '*.DELTA') -Destination $ResourceFolder
}
if (Test-Path $PermissionSetsPath) {
  Write-Host "Copying Permission Sets..."
  Copy-Item -Path (Join-Path $PermissionSetsPath '*.xml') -Destination $ResourceFolder
}
if (Test-Path $AddinsPath) {
  Write-Host "Copying Add-ins..."
  Copy-Item -Path (Join-Path $AddinsPath '*.dll') -Destination $ResourceFolder
}
if (Test-Path $WebServicesPath) {
  Write-Host "Copying Web Services..."
  Copy-Item -Path (Join-Path $WebServicesPath '*.xml') -Destination $ResourceFolder
}
if (Test-Path $TableDataPath) {
  Write-Host "Copying Table Data..."
  Copy-Item -Path (Join-Path $TableDataPath '*.xml') -Destination $ResourceFolder
}
if (Test-Path $CustomReportLayoutsPath) {
  Write-Host "Copying Custom Report Layouts..."
  Copy-Item -Path (Join-Path $CustomReportLayoutsPath '*.xml') -Destination $ResourceFolder
}
if (Test-Path $LanguagePath) {
  Write-Host "Copying Language..."
  Copy-Item -Path (Join-Path $LanguagePath '*.flm') -Destination $ResourceFolder
}

if ($SetupParameters.appIcon -ne "") {  
  $iconPath = (Get-ChildItem -Path $ImagesPath -Filter ($SetupParameters.appIcon + "*")).FullName
} else {
  $iconPath = ""
}

if (Test-Path $ScreenshotsPath) {
  $screenShots = (Get-ChildItem -Path $ScreenshotsPath).FullName
} else {
  $screenShots = @{}
}

$params = @{
      Path = $appPackageFileName 
      SourcePath = $ResourceFolder }
if ($iconPath -ne "") { if (Test-Path $iconPath) { $params.Logo = $iconPath } }
if ($screenShots.Count -gt 0) { $params.ScreenShots = $screenShots }

Get-NAVAppManifest `
  -Path $appManifastFilePath `
  | New-NAVAppPackage @params -Force 

Unload-AppsTools