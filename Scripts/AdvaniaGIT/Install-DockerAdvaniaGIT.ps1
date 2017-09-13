Function Install-DockerAdvaniaGIT {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )

    Invoke-WebRequest -Uri "https://github.com/gunnargestsson/AdvaniaGIT/archive/master.zip" -OutFile "$($SetupParameters.LogPath)\AdvaniaGIT.zip" -ErrorAction Stop
    $DockerSettings = Invoke-Command -Session $Session -ScriptBlock { 
        param([PSObject]$SetupParameters, [PSObject]$BranchSettings, [String]$GeoId, [String]$LocaleName )
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted 
        Set-WinHomeLocation -GeoId $GeoId
        Set-WinSystemLocale -SystemLocale $LocaleName
        Set-Culture -CultureInfo $LocaleName
        $AdvaniaGITZip = Join-Path (Join-Path "C:\Host\Log" (Split-Path $SetupParameters.LogPath -Leaf)) "AdvaniaGIT.zip"
        if (Test-Path -Path $AdvaniaGITZip) {
            Expand-Archive -LiteralPath $AdvaniaGITZip -DestinationPath "C:\"
            Rename-Item -Path "C:\AdvaniaGIT-master" -NewName "C:\AdvaniaGIT"
            Set-Location -Path "C:\AdvaniaGIT\Scripts"
            & .\Install-Modules.ps1 | Out-Null
            Write-Host "Updating BranchSettings.json..."
            $CustomConfigFile =  Join-Path $serviceTierFolder "CustomSettings.config"
            $CustomConfig = [xml](Get-Content $CustomConfigFile)
            $BranchSettings.instanceName = $customConfig.SelectSingleNode("//appSettings/add[@key='ServerInstance']").Value
            $BranchSettings.managementServicesPort = $customConfig.SelectSingleNode("//appSettings/add[@key='ManagementServicesPort']").Value
            $BranchSettings.databaseName = $customConfig.SelectSingleNode("//appSettings/add[@key='DatabaseName']").Value
            $BranchSettings.databaseInstance = $customConfig.SelectSingleNode("//appSettings/add[@key='DatabaseInstance']").Value
            $BranchSettings.clientServicesPort = $customConfig.SelectSingleNode("//appSettings/add[@key='ClientServicesPort']").Value
            $BranchSettings.developerServicesPort = $customConfig.SelectSingleNode("//appSettings/add[@key='DeveloperServicesPort']").Value
            $BranchSettings.databaseServer = $customConfig.SelectSingleNode("//appSettings/add[@key='DatabaseServer']").Value
            $BranchSettings.dockerContainerName = ""
            $BranchSettings.dockerContainerId = ""
            Update-BranchSettings -BranchSettings $BranchSettings -SettingsFilePath "C:\AdvaniaGIT\Data\BranchSettings.Json"
            Write-Host "Updating GITSettings.json..."
            $GITSettings = Get-GITSettings -SettingsFilePath "C:\AdvaniaGIT\Data\GITSettings.Json"
            $GITSettings.workFolder = "C:\Host\Workspace"
            $GITSettings.rootPath = "C:\Host"
            $GITSettings.ftpServer = $SetupParameters.ftpServer
            $GITSettings.ftpUser = $SetupParameters.ftpUser
            $GITSettings.ftpPass = $SetupParameters.ftpPass
            $GITSettings.licenseFile = $SetupParameters.licenseFile
            $GITSettings.objectsNotToDelete = $SetupParameters.objectsNotToDelete
            Update-GITSettings -GITSettings $GITSettings -SettingsFilePath "C:\AdvaniaGIT\Data\GITSettings.Json"
            Remove-Item -Path $AdvaniaGITZip -Force -ErrorAction SilentlyContinue
        } else {
            Write-Error "AdvaniaGIT Module Installation failed!" -ErrorAction Stop
        }
        $DockerSettings = New-Object -TypeName PSObject
        $DockerSettings | Add-Member -MemberType NoteProperty -Name GITSettings -Value $GITSettings
        $DockerSettings | Add-Member -MemberType NoteProperty -Name BranchSettings -Value $BranchSettings
        Return $DockerSettings
    } -ArgumentList ($SetupParameters, $BranchSettings, (Get-WinHomeLocation).GeoId, (Get-WinSystemLocale).Name)
    Return $DockerSettings
}