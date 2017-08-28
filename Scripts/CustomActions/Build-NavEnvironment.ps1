if ($SetupParameters.dockerImage -and $SetupParameters.dockerImage -gt "") {
    if ($BranchSettings.instanceName -eq "") {
        Write-Host "Starting Docker Image Development Container for Branch ..."
        Start-DockerContainer -SetupParameters $SetupParameters -BranchSettings $BranchSettings
        $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
    } 
}
if ($BranchSettings.dockerContainerName -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name
} else {
    Load-InstanceAdminTools -SetupParameters $Setupparameters
    if ($BranchSettings.instanceName -eq "") {
        Write-Host "Requesting new NAV Environment for branch" $Setupparameters.Branchname
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
        if ($DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='DeveloperServicesEnabled']")) {
            Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName DeveloperServicesEnabled -KeyValue $true
        }
        $BranchSettings.instanceName = $ServerInstance
        Enable-DelayedStartForNAVService -BranchSettings $BranchSettings
        Enable-TcpPortSharingForNAVService -BranchSettings $BranchSettings
        Write-Host "Starting Service..."
        Set-NAVServerInstance -ServerInstance $ServerInstance -Start -Force 
        Write-Host "Syncronizing Database..."
        Get-NAVServerInstance -ServerInstance $ServerInstance | Where-Object -Property State -EQ Running | Sync-NAVTenant -Mode ForceSync -Force
        Write-Host "Creating Web Server Instance..."
        New-NAVWebServerInstance -ClientServicesPort $BranchSettings.clientServicesPort -Server $env:COMPUTERNAME -ServerInstance $ServerInstance -WebServerInstance $ServerInstance -Force
        Update-BranchSettings -BranchSettings $BranchSettings
        Write-Host "Environment build completed..."
    } else {
        Write-Host "Environment already created..."
    }

    if (Test-Path $SetupParameters.LicenseFilePath) {  
        Update-NAVLicense -BranchSettings $BranchSettings -LicenseFilePath $SetupParameters.LicenseFilePath 
    }
    UnLoad-InstanceAdminTools

    if ($Setupparameters.uidOffset) {
        Write-Host "Set uidoffset in database $($BranchSettings.databaseName) to $($Setupparameters.uidOffset)"
        $command = 'UPDATE [dbo].[$ndo$dbproperty] SET [uidoffset] = ' + $Setupparameters.uidOffset
        $Result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command   
    }

}


