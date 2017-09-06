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
[String]$SourcePath,
[String]$LicensePath,
[String]$LicenseFilePath,
[String]$DownloadPath,
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
[String]$dockerContainerId,
[String]$dockerContainerName,
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
    $SetupParameters | Add-Member SourcePath  $BuildFolder
    $SetupParameters | Add-Member ExecutingBuild $true
} else {
    $SetupParameters | Add-Member "WorkFolder" $WorkFolder
    $SetupParameters | Add-Member "BackupPath" $BackupPath
    $SetupParameters | Add-Member "DatabasePath" $DatabasePath
    $SetupParameters | Add-Member "SourcePath" $SourcePath
    $SetupParameters | Add-Member "ExecutingBuild" $false
}    

$SetupParameters | Add-Member "SetupPath" $SetupPath
$SetupParameters | Add-Member "ObjectsPath" $ObjectsPath
$SetupParameters | Add-Member "DeltasPath" $DeltasPath
$SetupParameters | Add-Member "ReverseDeltasPath" $ReverseDeltasPath
$SetupParameters | Add-Member "ExtensionPath" $ExtensionPath
$SetupParameters | Add-Member "ImagesPath" $ImagesPath
$SetupParameters | Add-Member "ScreenshotsPath" $ScreenshotsPath
$SetupParameters | Add-Member "PermissionSetsPath" $PermissionSetsPath
$SetupParameters | Add-Member "AddinsPath" $AddinsPath
$SetupParameters | Add-Member "LanguagePath" $LanguagePath
$SetupParameters | Add-Member "TableDataPath" $TableDataPath
$SetupParameters | Add-Member "CustomReportLayoutsPath" $CustomReportLayoutsPath
$SetupParameters | Add-Member "WebServicesPath" $WebServicesPath
$SetupParameters | Add-Member "BinaryPath" $BinaryPath
$SetupParameters | Add-Member "LogPath" $LogPath
$SetupParameters | Add-Member "LicensePath" $LicensePath
$SetupParameters | Add-Member "LicenseFilePath" $LicenseFilePath
$SetupParameters | Add-Member "DownloadPath"  $DownloadPath
$SetupParameters | Add-Member "baseBranch" $baseBranch
$SetupParameters | Add-Member "branchId" $branchId
$SetupParameters | Add-Member "Branchname" $Branchname
$SetupParameters | Add-Member "codeSigningCertificate" $codeSigningCertificate
$SetupParameters | Add-Member "codeSigningCertificatePassword" $codeSigningCertificatePassword
$SetupParameters | Add-Member "datetimeCulture" $datetimeCulture
$SetupParameters | Add-Member "defaultDatabaseInstance" $defaultDatabaseInstance
$SetupParameters | Add-Member "defaultDatabaseServer" $defaultDatabaseServer
$SetupParameters | Add-Member "ftpPass" $ftpPass
$SetupParameters | Add-Member "ftpServer" $ftpServer
$SetupParameters | Add-Member "ftpUser" $ftpUser
$SetupParameters | Add-Member "licenseFile" $licenseFile
$SetupParameters | Add-Member "mainVersion" $mainVersion
$SetupParameters | Add-Member "navIdePath" $navIdePath
$SetupParameters | Add-Member "navRelease" $navRelease
$SetupParameters | Add-Member "navServicePath" $navServicePath
$SetupParameters | Add-Member "navSolution" $navSolution
$SetupParameters | Add-Member "navVersion" $navVersion
$SetupParameters | Add-Member "objectProperties" $objectProperties
$SetupParameters | Add-Member "objectsNotToDelete" $objectsNotToDelete
$SetupParameters | Add-Member "patchNoFunction" $patchNoFunction
$SetupParameters | Add-Member "projectName" $projectName
$SetupParameters | Add-Member "Repository" $Repository
$SetupParameters | Add-Member "rootPath" $rootPath
$SetupParameters | Add-Member "sigToolExecutable" $sigToolExecutable
$SetupParameters | Add-Member "storeAllObjects" $storeAllObjects
$SetupParameters | Add-Member "uidOffset" $uidOffset
if ($BuildSettings) { $SetupParameters = Combine-Settings $BuildSettings $SetupParameters }
	
# Set Branch Settings
$BranchSettings = New-Object PSObject
$BranchSettings | Add-Member "databaseName" $databaseName
$BranchSettings | Add-Member "branchId" $branchId
$BranchSettings | Add-Member "managementServicesPort" $managementServicesPort
$BranchSettings | Add-Member "projectName" $projectName
$BranchSettings | Add-Member "instanceName" $instanceName
$BranchSettings | Add-Member "databaseInstance" $databaseInstance
$BranchSettings | Add-Member "databaseServer" $databaseServer
$BranchSettings | Add-Member "clientServicesPort" $clientServicesPort
$BranchSettings | Add-Member "dockerContainerId" $dockerContainerId
$BranchSettings | Add-Member "dockerContainerName" $dockerContainerName
   
if ($BranchSettings.dockerContainerName -ne $null) {
    if ($BranchSettings.dockerContainerName -gt "") {
        $DockerContainerConfiguration = Get-DockerContainerConfiguration -DockerContainerName $BranchSettings.dockerContainerName 
    }
}

New-Item -Path (Split-Path -Path $SetupParameters.LogPath -Parent) -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $SetupParameters.LogPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    
# Start the script
$ScriptToStart = (Join-Path (Join-path $PSScriptRoot 'CustomActions') $ScriptName)
& $ScriptToStart 
Pop-Location
