Check-GitNotUnattached

Load-AppsTools -SetupParameters $SetupParameters
if (Test-Path $SetupParameters.ExtensionPath) 
{
  Remove-Item -Path $SetupParameters.ExtensionPath -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -Path $SetupParameters.ExtensionPath -ItemType Directory | Out-Null

$appManifastFilePath = (Join-Path $SetupParameters.ExtensionPath "AppManifest.xml")
$appPackageFileName = (Join-Path $SetupParameters.ExtensionPath 'AppPackage.navx')

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

$ResourceFolder = (Join-Path $SetupParameters.WorkFolder 'Resources')
Remove-Item -Path $ResourceFolder -Recurse -Force -ErrorAction SilentlyContinue
New-Item $ResourceFolder -ItemType Directory | Out-Null
if (Test-Path $SetupParameters.DeltasPath) {
  Write-Host "Copying Deltas..."
  Copy-Item -Path (Join-Path $SetupParameters.DeltasPath '*.DELTA') -Destination $ResourceFolder
}
if (Test-Path $SetupParameters.PermissionSetsPath) {
  Write-Host "Copying Permission Sets..."
  Copy-Item -Path (Join-Path $SetupParameters.PermissionSetsPath '*.xml') -Destination $ResourceFolder
}
if (Test-Path $SetupParameters.AddinsPath) {
  Write-Host "Copying Add-ins..."
  Copy-Item -Path (Join-Path $SetupParameters.AddinsPath '*.dll') -Destination $ResourceFolder
}
if (Test-Path $SetupParameters.WebServicesPath) {
  Write-Host "Copying Web Services..."
  Copy-Item -Path (Join-Path $SetupParameters.WebServicesPath '*.xml') -Destination $ResourceFolder
}
if (Test-Path $SetupParameters.TableDataPath) {
  Write-Host "Copying Table Data..."
  Copy-Item -Path (Join-Path $SetupParameters.TableDataPath '*.xml') -Destination $ResourceFolder
}
if (Test-Path $SetupParameters.CustomReportLayoutsPath) {
  Write-Host "Copying Custom Report Layouts..."
  Copy-Item -Path (Join-Path $SetupParameters.CustomReportLayoutsPath '*.xml') -Destination $ResourceFolder
}
if (Test-Path $SetupParameters.LanguagePath) {
  Write-Host "Copying Language..."
  Copy-Item -Path (Join-Path $SetupParameters.LanguagePath '*.flm') -Destination $ResourceFolder
}

if ($SetupParameters.appIcon -ne "") {  
  $iconPath = (Get-ChildItem -Path $SetupParameters.ImagesPath -Filter ($SetupParameters.appIcon + "*")).FullName
} else {
  $iconPath = ""
}

if (Test-Path $SetupParameters.ScreenshotsPath) {
  $screenShots = (Get-ChildItem -Path $SetupParameters.ScreenshotsPath).FullName
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