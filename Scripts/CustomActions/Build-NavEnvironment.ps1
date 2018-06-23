if (![String]::IsNullOrEmpty($SetupParameters.dockerImage)) {
    if ($BranchSettings.instanceName -eq "") {
        Write-Host "Starting Docker Image Development Container for Branch ..."
        $params = @{
            SetupParameters = $SetupParameters 
            BranchSettings = $BranchSettings
        }
        if ($SetupParameters.dockerAdminPasswordId) {
            Import-Module RemoteManagement -DisableNameChecking | Out-Null
            $DockerAdmin = Get-NAVPasswordStateUser -PasswordId $SetupParameters.dockerAdminPasswordId
            Write-Host "Using stored authentication for Docker Container..."
            $params += @{
                AdminUsername = $DockerAdmin.UserName 
                AdminPassword = $DockerAdmin.Password
            }
        }
        if ($SetupParameters.dockerMemoryLimit) {
            Write-Host "Using configured memory limit for Docker Container..."
            $params += @{                
                MemoryLimit = $SetupParameters.DockerMemoryLimit
            }
        }
        if ($SetupParameters.dockerRestoreBackup) {
            $BackupFilePath = Get-NAVBackupFilePath -SetupParameters $SetupParameters
            if (Test-Path -Path $BackupFilePath) {
                Write-Host "Using backup file for Docker Container..."
                $params += @{
                    BackupFilePath = $BackupFilePath
                }
            }
        }
        if (![string]::IsNullOrEmpty($SetupParameters.LicenseFilePath)) {
            if (Test-Path $SetupParameters.LicenseFilePath) {  
                    $params += @{
                        LicenseFilePath = $SetupParameters.LicenseFilePath
                    }
            }            
        }
        Start-DockerContainer @params
        $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
        & (Join-path $PSScriptRoot Verify-RepositorySetupInContainer.ps1)
    } 
}

if ($BranchSettings.dockerContainerName -gt "") {
    ReStart-DockerContainer -BranchSettings $BranchSettings
} else {
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    if ($BranchSettings.instanceName -eq "") {
        Write-Host "Requesting new NAV Environment for branch" $Setupparameters.projectName
        $BackupFilePath = Get-NAVBackupFilePath -SetupParameters $SetupParameters
        $ServerInstance = "NAV" + $($Setupparameters.navRelease) + "DEV" + (Get-EnvironmentNo)
        $params = @{ 
            BackupFilePath = $BackupFilePath
            DatabaseServer = $SetupParameters.defaultDatabaseServer
            DatabaseName = $ServerInstance
            DatabasePath = $SetupParameters.DatabasePath }
        if ($SetupParameters.defaultDatabaseInstance -ne "") { $params.DatabaseInstance = $SetupParameters.defaultDatabaseInstance }
        Write-Host "Restoring database..."
        Restore-NAVBackup @params
        Remove-Item -Path $BackupFilePath -Force -ErrorAction SilentlyContinue
        $BranchSettings.databaseInstance = $SetupParameters.defaultDatabaseInstance
        $BranchSettings.databaseServer = $SetupParameters.defaultDatabaseServer
        $BranchSettings.databaseName = $ServerInstance
        $BranchSettings.instanceName = "" 
        Write-Host "Upgrading database..."
        Invoke-NAVDatabaseConversion -SetupParameters $SetupParameters -BranchSettings $BranchSettings
        Write-Host "Simplifying Database..."
        Set-NAVDatabaseToSimpleRecovery -DatabaseServer $SetupParameters.defaultDatabaseServer -DatabaseInstance $SetupParameters.defaultDatabaseInstance -DatabaseName $ServerInstance
        Write-Host "Compiling Service Objects..."
        Compile-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Filter "Type=Table;Id=2000000004..2000000999" -SynchronizeSchemaChanges No 
        Write-Host "Creating Service..."
        $DefaultInstanceSettings = Get-DefaultInstanceSettings -SetupParameters $SetupParameters -BranchSettings $BranchSettings
        $BranchSettings.clientServicesPort = $DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ClientServicesPort']").Attributes["value"].Value
        $BranchSettings.managementServicesPort = $DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ManagementServicesPort']").Attributes["value"].Value
        $params = @{       
          ServerInstance = $ServerInstance 
          DatabaseName = $BranchSettings.databaseName
          DatabaseServer = $BranchSettings.databaseServer
          ManagementServicesPort = $DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ManagementServicesPort']").Attributes["value"].Value
          ClientServicesPort = $DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ClientServicesPort']").Attributes["value"].Value
          SOAPServicesPort = $DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='SOAPServicesPort']").Attributes["value"].Value
          ODataServicesPort = $DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ODataServicesPort']").Attributes["value"].Value          
        }
        if ($BranchSettings.databaseInstance -ne "") { $params.DatabaseInstance = $BranchSettings.databaseInstance }
        New-NAVServerInstance @params -Force -ServiceAccount NetworkService -ErrorAction Stop
        Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName ServicesDefaultTimeZone -KeyValue 'UTC' 
        Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName ServicesLanguage -KeyValue 'en-US' 
        Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName ODataServicesSSLEnabled -KeyValue $false 
        Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName ODataServicesEnabled -KeyValue $true 
        Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName SOAPServicesSSLEnabled -KeyValue $false 
        Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName SOAPServicesEnabled -KeyValue $true 
        Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName DataCacheSize -KeyValue 7 
        Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName CompileBusinessApplicationAtStartup -KeyValue $false
        Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName PublicWebBaseUrl -KeyValue "http://$($env:COMPUTERNAME):$(Get-WebClientPort -MainVersion $SetupParameters.mainVersion)/${ServerInstance}/WebClient"
        if ($SetupParameters.developerService -eq $true) {
            Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName DeveloperServicesEnabled -KeyValue $true 
            Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName DefaultClient -KeyValue 'Web'
            $BranchSettings.developerServicesPort = $DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='DeveloperServicesPort']").Attributes["value"].Value
        }
        if ($DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='DeveloperServicesEnabled']")) {
            Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName DeveloperServicesEnabled -KeyValue $true
            $BranchSettings.developerServicesPort = ""
        }
        $BranchSettings.instanceName = $ServerInstance
        Enable-DelayedStartForNAVService -BranchSettings $BranchSettings
        Enable-TcpPortSharingForNAVService -BranchSettings $BranchSettings
        Write-Host "Starting Service..."
        Set-NAVServerInstance -ServerInstance $ServerInstance -Start -Force 
        Write-Host "Syncronizing Database..."
        Get-NAVServerInstance -ServerInstance $ServerInstance | Where-Object -Property State -EQ Running | Sync-NAVTenant -Mode ForceSync -Force
        Write-Host "Creating Web Server Instance..."
        New-NAVWebServerInstance -ClientServicesPort $BranchSettings.clientServicesPort -Server $env:COMPUTERNAME -ServerInstance $ServerInstance -WebServerInstance $ServerInstance
        Enable-NAVWebClientDesigner -BranchSettings $BranchSettings
        Enable-NAVWebClientPersonalization -BranchSettings $BranchSettings
        Update-BranchSettings -BranchSettings $BranchSettings
        Write-Host "Environment build completed..."
    } else {
        Write-Host "Environment already created..."
    }

    if (![string]::IsNullOrEmpty($SetupParameters.LicenseFilePath)) {
        if (Test-Path $SetupParameters.LicenseFilePath) {  
            Update-NAVLicense -BranchSettings $BranchSettings -LicenseFilePath $SetupParameters.LicenseFilePath 
        }
    }
    UnLoad-InstanceAdminTools

}

if (![string]::IsNullOrEmpty($Setupparameters.uidOffset)) {
    Write-Host "Set uidoffset in database $($BranchSettings.databaseName) to $($Setupparameters.uidOffset)"
    $command = 'UPDATE [dbo].[$ndo$dbproperty] SET [uidoffset] = ' + $Setupparameters.uidOffset
    $Result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command   
}
