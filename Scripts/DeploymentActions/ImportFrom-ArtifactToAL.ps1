$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

$WorkFolder = $DeploymentSettings.workFolder
if (!(Test-Path -Path $WorkFolder)) {New-Item -Path $WorkFolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null}
Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer -SetupPath $WorkFolder


if (Get-ChildItem -Path (Get-Location).Path -Filter *.app) {
    Write-Host "Uploading Artifact AL to remote server as App.zip..."
    Compress-Archive -Path (Join-Path (Get-Location).Path *.app) -DestinationPath (Join-Path $WorkFolder 'App.zip') -Force
    Copy-FileToRemoteMachine -Session $Session -SourceFile (Join-Path $WorkFolder 'App.zip') -DestinationFile (Join-Path $WorkFolder "$($DeploymentSettings.instanceName)-App.zip") 
    Remove-Item -Path (Join-Path $WorkFolder 'App.zip')  -Force -ErrorAction SilentlyContinue

    Write-Host "Expanding App.zip on remote server..."
    Invoke-Command -Session $Session -ScriptBlock {
        param([string]$ZipFileName,[string]$AppFilePath)
        Write-Host Importing modules from $($SetupParameters.navServicePath)...
        Load-InstanceAdminTools -SetupParameters $SetupParameters
        Load-InstanceAppTools -SetupParameters $SetupParameters        
        if (!(Test-Path -Path $AppFilePath)) { New-Item -Path $AppFilePath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null }
        $TempFilePath = Join-Path $AppFilePath (New-Guid)
        New-Item -Path $TempFilePath -ItemType Directory | Out-Null
        Expand-Archive -Path $ZipFileName -DestinationPath $TempFilePath -Force
        Remove-Item -Path $ZipFileName -Force -ErrorAction SilentlyContinue

        if (Test-Path -Path $TempFilePath -PathType Leaf) {
            $App = (Get-ChildItem -Path $TempFilePath -Filter "*.app")[0]
            $AppToInstall = Get-NAVAppInfo -Path $App.FullName
            Copy-Item -Path $App.FullName -Destination (Join-Path $AppFilePath "$($AppToInstall.appId).app") -Force
            Remove-Item -Path $TempFilePath -Recurse -Force
        } else {
            foreach ($App in (Get-ChildItem -Path $TempFilePath -Filter "*.app")) {
                $AppToInstall = Get-NAVAppInfo -Path $App.FullName
                Copy-Item -Path $App.FullName -Destination (Join-Path $AppFilePath "$($AppToInstall.appId).app") -Force
            }
            Remove-Item -Path $TempFilePath -Recurse -Force
        }
    } -ArgumentList ((Join-Path $WorkFolder "$($DeploymentSettings.instanceName)-App.zip"), "${WorkFolder}\$($DeploymentSettings.instanceName)")

    Write-Host "App upload complete..."
}

$Session | Remove-PSSession
