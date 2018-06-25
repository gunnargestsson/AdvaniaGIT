$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

$WorkFolder = $DeploymentSettings.workFolder
if (!(Test-Path -Path $WorkFolder)) {New-Item -Path $WorkFolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null}
Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer -SetupPath $WorkFolder

if (Test-Path -Path (Join-Path $workFolder "*.txt")) {
    Write-Host "Uploading Translations Artifacts to remote server as Translations.zip..."
    Compress-Archive -Path (Join-Path (Get-Location).Path "*.txt") -DestinationPath (Join-Path $WorkFolder 'Translations.zip') -Force
    Copy-FileToRemoteMachine -Session $Session -SourceFile (Join-Path $WorkFolder 'Translations.zip') -DestinationFile (Join-Path $WorkFolder "$($DeploymentSettings.instanceName)-Translations.zip") 
    Remove-Item -Path (Join-Path $WorkFolder 'Translations.zip')  -Force -ErrorAction SilentlyContinue

    Write-Host "Expanding Translations.zip on remote server..."
    Invoke-Command -Session $Session -ScriptBlock {
        param([string]$ZipFileName,[string]$TranslationFilePath)
        if (!(Test-Path -Path $TranslationFilePath)) { New-Item -Path $TranslationFilePath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null }
        Expand-Archive -Path $ZipFileName -DestinationPath $TranslationFilePath -Force
        Remove-Item -Path $ZipFileName -Force -ErrorAction SilentlyContinue
    } -ArgumentList ((Join-Path $WorkFolder "$($DeploymentSettings.instanceName)-Translations.zip"), "${WorkFolder}\$($DeploymentSettings.instanceName)")

    Write-Host "Copying Translations Artifacts to service instance $($DeploymentSettings.instanceName)..."
    Invoke-Command -Session $Session -ScriptBlock {
        param([string]$filePath)
        Load-InstanceAdminTools -SetupParameters $SetupParameters
        if (Get-NAVServerInstance -ServerInstance $DeploymentSettings.instanceName | Where-Object -Property Default -eq True) { 
            $TranslationsPath = Join-Path $SetupParameters.navServicePath "Translations"
        } else { 
            $TranslationsPath = Join-Path $SetupParameters.navServicePath "Instances\$($DeploymentSettings.instanceName)\Translations"
        }

        Copy-Item -Path (Join-Path $filePath "*.txt") -Destination $TranslationsPath -Force
        Remove-Item -Path (Join-Path $filePath "*.txt")  -Force -ErrorAction SilentlyContinue
        Set-NAVServerInstance -ServerInstance $DeploymentSettings.instanceName -Restart
    } -ArgumentList (Join-Path $WorkFolder $($DeploymentSettings.instanceName))

    Write-Host "Translations Import complete..."
}

$Session | Remove-PSSession
