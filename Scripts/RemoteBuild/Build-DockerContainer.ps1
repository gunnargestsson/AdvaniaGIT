# Import all needed modules
Get-Module RemoteManagement | Remove-Module
Get-Module AdvaniaGIT | Remove-Module
Import-Module RemoteManagement -DisableNameChecking | Out-Null
Import-Module AdvaniaGIT -DisableNameChecking | Out-Null

# Get Environment Settings
$SetupParameters = Get-GITSettings
$RemoteConfig = Get-NAVRemoteConfig
 
$VMAdmin = Get-NAVPasswordStateUser -PasswordId $RemoteConfig.VMUserPasswordID
if ($VMAdmin.UserName -gt "" -and $VMAdmin.Password -gt "") {
    $VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))
} else {
    $VMCredential = Get-Credential -Message "Admin Access to Azure SQL" -ErrorAction Stop    
}

if (!$VMCredential.UserName -or !$VMCredential.Password) {
    Write-Host -ForegroundColor Red "Credentials required!"
    break
}

$BuildServer = 'advanianavbuild-01.westeurope.cloudapp.azure.com'
$BranchPath = 'C:\NAVManagementWorkFolder\Workspace\GIT\Advania\nav2018'
$LicenseFile = 'C:\NAVManagementWorkFolder\License\Advania.flf'

$BuildFolder = New-Guid
$WorkFolder = Join-Path 'C:\AdvaniaGIT\Workspace' $BuildFolder
New-Item -Path $WorkFolder -ItemType Directory
Write-Host "Connecting to Build Server ${BuildServer},..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $BuildServer -SetupPath $WorkFolder
$BranchSetup = Get-Content -Path (Join-Path $BranchPath "Setup.json") -Encoding UTF8 | Out-String | ConvertFrom-Json
New-NAVRemoteBranchSettingsObject -Session $Session -BranchSetup $BranchSetup 

New-NAVRemoteDockerContainer -Session $Session -BranchSetup $BranchSetup -AdminPassword ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($VMCredential.Password)))

$ObjectsAvailable = (Test-Path -Path (Join-Path $BranchPath "Objects"))
if ($ObjectsAvailable) {
    Write-Host "Uploading Objects from GIT..."
    Compress-Archive -Path (Join-Path $BranchPath "Objects") -DestinationPath (Join-Path $WorkFolder 'Objects.zip') -Force
    Copy-FileToRemoteMachine -Session $Session -SourceFile (Join-Path $WorkFolder 'Objects.zip') -DestinationFile (Join-Path $WorkFolder 'Objects.zip') 
    Remove-Item -Path (Join-Path $WorkFolder 'Objects.zip')  -Force -ErrorAction SilentlyContinue
}

$TestsAvailable = (Test-Path -Path (Join-Path $BranchPath "TestToolKit"))
if ($TestsAvailable) {
    Write-Host "Uploading Test Objects from GIT..."
    Compress-Archive -Path (Join-Path $BranchPath "TestToolKit") -DestinationPath (Join-Path $WorkFolder 'TestToolKit.zip') -Force
    Copy-FileToRemoteMachine -Session $Session -SourceFile (Join-Path $WorkFolder 'TestToolKit.zip') -DestinationFile (Join-Path $WorkFolder 'TestToolKit.zip') 
    Remove-Item -Path (Join-Path $WorkFolder 'TestToolKit.zip')  -Force -ErrorAction SilentlyContinue
}

Write-Host "Update NAV license in Docker Container..."
Copy-FileToRemoteMachine -Session $Session -SourceFile $LicenseFile -DestinationFile (Join-Path $WorkFolder 'license.flf')
Import-NAVRemoteLicenseToDockerContainer -Session $Session -LicenseFile (Join-Path $WorkFolder 'license.flf') 

Write-Host "Importing objects into Docker Container..."
if ($ObjectsAvailable) {
    Import-NAVRemoteObjectsToDockerContainer -Session $Session -DestinationZipFile (Join-Path $WorkFolder 'Objects.zip') 
}
if ($TestsAvailable) {
    Import-NAVRemoteObjectsToDockerContainer -Session $Session -DestinationZipFile (Join-Path $WorkFolder 'TestToolKit.zip') 
}

Write-Host "Compiling all objects in Docker Container..."
Compile-NAVRemoteObjectsInDockerContainer -Session $Session 

$CertificateInfo = Get-NAVPasswordStateUser -PasswordId '13774'
Copy-NAVRemoteCertificateToWorkfolder -Session $Session -CertificatePath $CertificateInfo.GenericField2 -Workfolder $WorkFolder
Set-NAVRemoteDockerContainerServerInstanceToNAVUserPassword -Session $Session -CertificateFileName (Join-Path $WorkFolder (Split-Path $CertificateInfo.GenericField2 -Leaf)) -CertificatePassword $CertificateInfo.Password 

Write-Host "Create NAV users..."
$NavUser = "TestUser"
$NavPassword = Get-NewUserPassword 

New-NAVRemoteDockerContainerUser -Session $Session -UserName $NavUser -Password $NavPassword

Write-Host "Starting all unit tests in Docker Container..."
Start-NAVRemoteUnitTestsDockerContainer -Session $Session -UserName $NavUser -Password $NavPassword
