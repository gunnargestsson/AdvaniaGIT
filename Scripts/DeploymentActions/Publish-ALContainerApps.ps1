$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

$WorkFolder = $DeploymentSettings.workFolder
if (!(Test-Path -Path $WorkFolder)) {New-Item -Path $WorkFolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null}
if (![String]::IsNullOrEmpty(($DeploymentSettings.LockFile))) {
    if (!(Test-Path -Path $DeploymentSettings.LockFile)) { Set-Content -Path $DeploymentSettings.LockFile -Value 'Lock File' }
    $file = $null
        while (!($file)) {
            try {
                $file = [System.IO.File]::Open($DeploymentSettings.LockFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::Read)
            } catch [System.IO.IOException]  {
                Write-Host "Waiting for previous publish process to finish..."
                Start-Sleep -Seconds 10
            }
        }
}
$host.SetShouldExit(0)

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer -SetupPath $WorkFolder

Get-ChildItem -Path (Get-Location).Path -Filter *Test*.app | Remove-Item

if (Get-ChildItem -Path (Get-Location).Path -Filter *.app) {

    $RandomCharacters = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
    $zipFileName = $RandomCharacters + "App.zip"
    $TempFilePath = $env:TEMP

    Write-Host "Uploading Artifact AL to remote server as App.zip..."
    Compress-Archive -Path (Join-Path (Get-Location).Path *.app) -DestinationPath (Join-Path $TempFilePath $zipFileName) -Force
    Copy-FileToRemoteMachine -Session $Session -SourceFile (Join-Path $TempFilePath $zipFileName) -DestinationFile "${WorkFolder}\$($DeploymentSettings.containerName)-App.zip"
    Remove-Item -Path (Join-Path $TempFilePath $zipFileName)  -Force -ErrorAction SilentlyContinue

    Write-Host "Expanding App.zip on remote server..."
    #
    if ($($DeploymentSettings.ManualStartBy) -eq '${bamboo.ManualBuildTriggerReason.userName}') {
       $DeploymentSettings.ManualStartBy = ''
    }
    Write-Host "ManualStartBy:" $DeploymentSettings.ManualStartBy "..."
    #
    Invoke-Command -Session $Session -ScriptBlock {
        param([string]$containerName,[string]$ZipFileName,[string]$AppFilePath,[string]$Publisher,[boolean]$uninstall)
        Write-Host Importing BCContainerHelper
        Import-Module BCContainerHelper -DisableNameChecking

        if (!(Test-Path -Path $AppFilePath)) { New-Item -Path $AppFilePath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null }

        $TempFilePath = Join-Path $AppFilePath (New-Guid)
        New-Item -Path $TempFilePath -ItemType Directory | Out-Null
        Expand-Archive -Path $ZipFileName -DestinationPath $TempFilePath -Force
        Remove-Item -Path $ZipFileName -Force -ErrorAction SilentlyContinue

        Write-Host "Container deployment to ${containerName}"
        
        foreach ($appFile in (Get-ChildItem -Path $TempFilePath -Filter "*.app")) {
            Write-Host Publishing $($appFile.BaseName)...
            Copy-Item -Path $appFile.FullName -Destination "C:\ProgramData\BCContainerHelper\Extensions\${containerName}\My" -Force
            $appInfo = Invoke-ScriptInBCContainer -containerName $containerName -scriptblock {
                param([string]$appFileName)
                $appInfo = Get-NAVAppInfo -Path (Join-Path "C:\Run\My" $appFileName)                
                return $appInfo
            } -argumentList ($appFile.Name)
            Write-Host "Deploying $($appInfo.Name) version $($appInfo.Version) by $($appInfo.Publisher) to ${containerName}"            
            $tenants = Get-BCContainerTenants -containerName $containerName 
            try {                
                $appsToUnPublish = Get-BCContainerAppInfo $containerName | Where-Object -Property appid -EQ $appInfo.appid | Where-Object version -LT $appInfo.version
                
                Write-Host "Publish new version"
                Publish-BCContainerApp -containerName $containerName -appFile $appFile.FullName -skipVerification -sync -scope Global
                
                Write-Host "Upgrade app in tenant : "
                foreach ($tenant in $tenants.id) {
                    Write-Host "- $tenant"
                    Sync-BCContainerApp -containerName $containerName -appName $appInfo.name -appVersion $appInfo.version -tenant $tenant
                    Get-BCContainerAppInfo $containerName -tenantSpecificProperties -tenant $tenant | Where-Object -Property appid -EQ $appInfo.appid | Where-Object -Property version -LT $appInfo.version | Where-Object -Property IsInstalled -EQ "True" | % {
                        Write-Host "Installed app found: $($_.Name) v$($_.version) by $($_.publisher)"
                        Start-BCContainerAppDataUpgrade -containerName $containerName -appName $appInfo.name -appVersion $appInfo.version -tenant $tenant
                    }                    
                }

                Write-Host "Install app in tenant : "
                foreach ($tenant in $tenants.id) {
                    Write-Host "- $tenant" 
                    Install-BCContainerApp -containerName $containerName -appName $appInfo.name -appVersion $appInfo.version -tenant $tenant
                }

                $appsToUnPublish | % {
                    Write-Host "Unpublish previous versions"
                    UnPublish-BCContainerApp -containerName $containerName -appName $_.name -publisher $_.publisher -version $_.Version -force
                }
            }
            catch  {
                throw "Could not publish $($appInfo.name) to ${containerName}"
            }
            finally { } 
        }                     
        Remove-Item -Path $TempFilePath -Recurse -Force  
             
    } -ArgumentList ($DeploymentSettings.containerName, "${WorkFolder}\$($DeploymentSettings.containerName)-App.zip", "${WorkFolder}\$($DeploymentSettings.containerName)", $DeploymentSettings.publisher, [String]::IsNullOrEmpty($DeploymentSettings.ManualStartBy))

    Write-Host "App upload complete..."
}

$Session | Remove-PSSession
if (![String]::IsNullOrEmpty(($DeploymentSettings.LockFile))) { $file.Dispose() }
