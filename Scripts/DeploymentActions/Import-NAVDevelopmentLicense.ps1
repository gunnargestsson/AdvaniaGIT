$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

$WorkFolder = $DeploymentSettings.workFolder
if (!(Test-Path -Path $WorkFolder)) {New-Item -Path $WorkFolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null}
Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer -SetupPath $WorkFolder

$LicensePath = Join-Path (Join-Path $SetupParameters.rootPath "License") $SetupParameters.licenseFile

if (Test-Path -Path $LicensePath) {
    Write-Host "Uploading License to remote server..."
    Copy-FileToRemoteMachine -Session $Session -SourceFile $LicensePath -DestinationFile (Join-Path $WorkFolder "$($DeploymentSettings.instanceName)-License.flf") 

    Write-Host "Installing License to service instance $($DeploymentSettings.instanceName)..."
    Invoke-Command -Session $Session -ScriptBlock {
        param([string]$filePath,[string]$instanceName)
        Load-InstanceAdminTools -SetupParameters $SetupParameters
        Import-NAVServerLicense -ServerInstance $instanceName -LicenseFile $filePath -Database NavDatabase
        Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue
    } -ArgumentList (Join-Path $WorkFolder "$($DeploymentSettings.instanceName)-License.flf"), $DeploymentSettings.instanceName

    Write-Host "License Import complete..."
}

$Session | Remove-PSSession
