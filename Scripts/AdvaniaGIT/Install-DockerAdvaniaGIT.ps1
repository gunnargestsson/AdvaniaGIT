Function Install-DockerAdvaniaGIT {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )

    Invoke-Command -Session $Session -ScriptBlock { 
        param([PSObject]$SetupParameters, [PSObject]$BranchSettings, [String]$GeoId, [String]$LocaleName )
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted 
        Set-WinHomeLocation -GeoId $GeoId
        Set-WinSystemLocale -SystemLocale $LocaleName
        Set-Culture -CultureInfo $LocaleName
        Invoke-WebRequest -Uri "https://github.com/gunnargestsson/AdvaniaGIT/archive/master.zip" -OutFile "C:\Run\AdvaniaGIT.zip" -ErrorAction Stop
        if (Test-Path -Path "C:\Run\AdvaniaGIT.zip") {
            Expand-Archive -LiteralPath "C:\Run\AdvaniaGIT.zip" -DestinationPath "C:\"
            Rename-Item -Path "C:\AdvaniaGIT-master" -NewName "C:\AdvaniaGIT"
            Set-Location -Path "C:\AdvaniaGIT\Scripts"
            & .\Install-Modules.ps1
            Write-Host "Updating BranchSettings.json..."
            $CustomConfigFile =  Join-Path $serviceTierFolder "CustomSettings.config"
            $CustomConfig = [xml](Get-Content $CustomConfigFile)
            $BranchSettings.instanceName = $customConfig.SelectSingleNode("//appSettings/add[@key='ServerInstance']").Value
            $BranchSettings.managementServicesPort = $customConfig.SelectSingleNode("//appSettings/add[@key='ManagementServicesPort']").Value
            $BranchSettings.databaseName = $customConfig.SelectSingleNode("//appSettings/add[@key='DatabaseName']").Value
            $BranchSettings.databaseInstance = $customConfig.SelectSingleNode("//appSettings/add[@key='DatabaseInstance']").Value
            $BranchSettings.clientServicesPort = $customConfig.SelectSingleNode("//appSettings/add[@key='ClientServicesPort']").Value
            $BranchSettings.databaseServer = $customConfig.SelectSingleNode("//appSettings/add[@key='DatabaseServer']").Value
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
        } else {
            Write-Error "AdvaniaGIT Module Installation failed!" -ErrorAction Stop
        }
        
    } -ArgumentList ($SetupParameters, $BranchSettings, (Get-WinHomeLocation).GeoId, (Get-WinSystemLocale).Name)
}