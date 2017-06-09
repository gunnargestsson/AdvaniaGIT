param
(
[Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
[String]$ScriptName,
[String]$Repository,
[String]$WorkFolder,
[String]$SetupPath,
[String]$ObjectsPath,
[String]$DeltasPath,
[String]$ReverseDeltasPath,
[String]$ExtensionPath,
[String]$ImagesPath,
[String]$ScreenshotsPath,
[String]$PermissionSetsPath,
[String]$AddinsPath,
[String]$LanguagePath,
[String]$TableDataPath,
[String]$CustomReportLayoutsPath,
[String]$WebServicesPath,
[String]$BinaryPath,
[String]$LogPath=$Env:TEMP,
[String]$BackupPath,
[String]$DatabasePath,
[String]$LicensePath,
[String]$LicenseFilePath,
[String]$baseBranch,
[String]$branchId,
[String]$Branchname,
[String]$codeSigningCertificate,
[String]$codeSigningCertificatePassword,
[String]$datetimeCulture,
[String]$defaultDatabaseInstance,
[String]$defaultDatabaseServer,
[String]$ftpPass,
[String]$ftpServer,
[String]$ftpUser,
[String]$licenseFile,
[String]$mainVersion,
[String]$navIdePath,
[String]$navRelease,
[String]$navServicePath,
[String]$navSolution,
[String]$navVersion,
[String]$objectProperties,
[String]$objectsNotToDelete,
[String]$patchNoFunction,
[String]$projectName,
[String]$rootPath,
[String]$sigToolExecutable,
[String]$storeAllObjects,
[String]$uidOffset,
[String]$databaseName,
[String]$managementServicesPort,
[String]$instanceName,
[String]$databaseInstance,
[String]$databaseServer,
[String]$clientServicesPort,
[String]$BuildFolder,
[HashTable]$BuildSettings
)

# Import all needed modules
Import-Module AdvaniaGIT -DisableNameChecking | Out-Null
    
# Set Environment Settings
$SetupParameters = New-Object -TypeName PSObject

if ($BuildFolder) {
    $SetupParameters | Add-Member WorkFolder $BuildFolder
    $SetupParameters | Add-Member BackupPath  $BuildFolder
    $SetupParameters | Add-Member DatabasePath  $BuildFolder
    $SetupParameters | Add-Member ExecutingBuild $true
} else {
    $SetupParameters | Add-Member WorkFolder $WorkFolder
    $SetupParameters | add-member "BackupPath" $BackupPath
    $SetupParameters | add-member "DatabasePath" $DatabasePath
    $SetupParameters | Add-Member ExecutingBuild $false
}    

$SetupParameters | add-member "SetupPath" $SetupPath
$SetupParameters | add-member "ObjectsPath" $ObjectsPath
$SetupParameters | add-member "DeltasPath" $DeltasPath
$SetupParameters | add-member "ReverseDeltasPath" $ReverseDeltasPath
$SetupParameters | add-member "ExtensionPath" $ExtensionPath
$SetupParameters | add-member "ImagesPath" $ImagesPath
$SetupParameters | add-member "ScreenshotsPath" $ScreenshotsPath
$SetupParameters | add-member "PermissionSetsPath" $PermissionSetsPath
$SetupParameters | add-member "AddinsPath" $AddinsPath
$SetupParameters | add-member "LanguagePath" $LanguagePath
$SetupParameters | add-member "TableDataPath" $TableDataPath
$SetupParameters | add-member "CustomReportLayoutsPath" $CustomReportLayoutsPath
$SetupParameters | add-member "WebServicesPath" $WebServicesPath
$SetupParameters | add-member "BinaryPath" $BinaryPath
$SetupParameters | add-member "LogPath" $LogPath
$SetupParameters | add-member "LicensePath" $LicensePath
$SetupParameters | add-member "LicenseFilePath" $LicenseFilePath
$SetupParameters | add-member "baseBranch" $baseBranch
$SetupParameters | add-member "branchId" $branchId
$SetupParameters | add-member "Branchname" $Branchname
$SetupParameters | add-member "codeSigningCertificate" $codeSigningCertificate
$SetupParameters | add-member "codeSigningCertificatePassword" $codeSigningCertificatePassword
$SetupParameters | add-member "datetimeCulture" $datetimeCulture
$SetupParameters | add-member "defaultDatabaseInstance" $defaultDatabaseInstance
$SetupParameters | add-member "defaultDatabaseServer" $defaultDatabaseServer
$SetupParameters | add-member "ftpPass" $ftpPass
$SetupParameters | add-member "ftpServer" $ftpServer
$SetupParameters | add-member "ftpUser" $ftpUser
$SetupParameters | add-member "licenseFile" $licenseFile
$SetupParameters | add-member "mainVersion" $mainVersion
$SetupParameters | add-member "navIdePath" $navIdePath
$SetupParameters | add-member "navRelease" $navRelease
$SetupParameters | add-member "navServicePath" $navServicePath
$SetupParameters | add-member "navSolution" $navSolution
$SetupParameters | add-member "navVersion" $navVersion
$SetupParameters | add-member "objectProperties" $objectProperties
$SetupParameters | add-member "objectsNotToDelete" $objectsNotToDelete
$SetupParameters | add-member "patchNoFunction" $patchNoFunction
$SetupParameters | add-member "projectName" $projectName
$SetupParameters | add-member "Repository" $Repository
$SetupParameters | add-member "rootPath" $rootPath
$SetupParameters | add-member "sigToolExecutable" $sigToolExecutable
$SetupParameters | add-member "storeAllObjects" $storeAllObjects
$SetupParameters | add-member "uidOffset" $uidOffset

# Set Branch Settings
$BranchSettings = New-Object PSObject
$BranchSettings | add-member "databaseName" $databaseName
$BranchSettings | add-member "branchId" $branchId
$BranchSettings | add-member "managementServicesPort" $managementServicesPort
$BranchSettings | add-member "projectName" $projectName
$BranchSettings | add-member "instanceName" $instanceName
$BranchSettings | add-member "databaseInstance" $databaseInstance
$BranchSettings | add-member "databaseServer" $databaseServer
$BranchSettings | add-member "clientServicesPort" $clientServicesPort
   
New-Item -Path (Split-Path -Path $SetupParameters.LogPath -Parent) -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $SetupParameters.LogPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    
# Start the script
$ScriptToStart = (Join-Path (Join-path $PSScriptRoot 'CustomActions') $ScriptName)
& $ScriptToStart 
Pop-Location
