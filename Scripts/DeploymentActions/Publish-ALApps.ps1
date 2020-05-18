$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

$WorkFolder = $DeploymentSettings.workFolder
if (!(Test-Path -Path $WorkFolder)) {New-Item -Path $WorkFolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null}
Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer -SetupPath $WorkFolder

Get-ChildItem -Path (Get-Location).Path -Filter *Test*.app | Remove-Item

if (Get-ChildItem -Path (Get-Location).Path -Filter *.app) {

    $RandomCharacters = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
    $zipFileName = $RandomCharacters + "App.zip"

    Write-Host "Uploading Artifact AL to remote server as App.zip..."
    Compress-Archive -Path (Join-Path (Get-Location).Path *.app) -DestinationPath (Join-Path $WorkFolder $zipFileName) -Force
    Copy-FileToRemoteMachine -Session $Session -SourceFile (Join-Path $WorkFolder $zipFileName) -DestinationFile (Join-Path $WorkFolder "$($DeploymentSettings.instanceName)-App.zip") 
    Remove-Item -Path (Join-Path $WorkFolder $zipFileName)  -Force -ErrorAction SilentlyContinue

    Write-Host "Expanding App.zip on remote server..."
    Invoke-Command -Session $Session -ScriptBlock {
        param([string]$ServerInstance,[string]$ZipFileName,[string]$AppFilePath,[string]$Publisher,[string]$mainVersion)
        if ($mainVersion) {
            $SetupParameters.mainVersion = $mainVersion
        }
        $SetupParameters | Add-Member "navServicePath" (Get-NAVServicePath -SetupParameters $SetupParameters) -Force
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
            Write-Host Publishing $($App.BaseName)...
            Publish-NAVApp -ServerInstance $ServerInstance -Path $App.FullName
        } else {
            foreach ($App in (Get-ChildItem -Path $TempFilePath -Filter "*.app")) {
                Write-Host Publishing $($App.BaseName)...
                Publish-NAVApp -ServerInstance $ServerInstance -Path $App.FullName
            }            
        }
        Remove-Item -Path $TempFilePath -Recurse -Force

        $tenants = Get-NAVTenant -ServerInstance $ServerInstance 
        foreach ($tenant in $tenants) {
            $installedApps = Get-NAVAppInfo -ServerInstance $ServerInstance -Tenant $tenant.Id 
            foreach ($installedApp in $installedApps) {        
                Write-Host Looking for a newer version of app $($installedApp.Name)
                $availableApp = Get-NAVAppInfo -ServerInstance $ServerInstance -Id $installedApp.AppId | Where-Object -Property Version -gt $installedApp.Version | Sort-Object -Property Version | Select-Object -Last 1
                if ($availableApp) {
                    Write-Host Upgrading to version $availableApp.Version 
                    #Uninstall-NAVApp $ServerInstance -Tenant $tenant.id -AppName $installedApp.Name -Version $installedApp.Version
                    Sync-NAVApp -ServerInstance $ServerInstance -Tenant $tenant.id -AppName $installedApp.Name -Version $availableApp.Version #-Mode ForceSync -Force
                    Start-NAVAppDataUpgrade -ServerInstance $ServerInstance -Tenant $tenant.id -AppName $installedApp.Name -Version $availableApp.Version -Language is-IS
                }
            }
        }

        $installedApps = @()

        $tenants = Get-NAVTenant -ServerInstance $ServerInstance 
        foreach ($tenant in $tenants) {
            $installedApps += Get-NAVAppInfo -ServerInstance $ServerInstance -Tenant $tenant.Id | Where-Object -Property Publisher -EQ $Publisher
        }

        foreach ($publishedApp in (Get-NAVAppInfo -ServerInstance $ServerInstance | Where-Object -Property Publisher -EQ $Publisher | Sort-Object -Property Name)) {        
            if ($installedApps | Where-Object -Property appId -EQ $publishedApp.appId | Where-Object -Property Version -EQ $publishedApp.Version) {
                Write-Host App $($publishedApp.Name) version $($publishedApp.Version) is in use
            } else {
                Write-Host Unpublishing App $($publishedApp.Name) version $($publishedApp.Version)
                Unpublish-NAVApp -ServerInstance $ServerInstance -Name $publishedApp.Name -Publisher $publishedApp.Publisher -Version $publishedApp.Version
            }
        }


    } -ArgumentList ($DeploymentSettings.instanceName, (Join-Path $WorkFolder "$($DeploymentSettings.instanceName)-App.zip"), "${WorkFolder}\$($DeploymentSettings.instanceName)", $DeploymentSettings.publisher, $DeploymentSettings.mainVersion)

    Write-Host "App upload complete..."
}

$Session | Remove-PSSession
