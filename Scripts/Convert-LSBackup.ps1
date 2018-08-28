# Script made to convert the LS database to enable for source control (remove ndf file).
# Gunnar Gestsson, 2017.
# Update these two lines
$version = '110'
$backupFilePath = 'C:\AdvaniaGIT\BACKUP\FastLane2018.bak'

# Import all needed modules
Get-Module -Name AdvaniaGIT | Remove-Module
Import-Module AdvaniaGIT -DisableNameChecking | Out-Null

if (!(Test-Path -Path $backupFilePath)) { Show-Error -ErrorMessage "File not found!" }
$backupFilePath = Get-Item $backupFilePath
$dbName = $backupFilePath.BaseName
$navDataFileName = (Join-Path $Env:TEMP "$dbName.navdata")
$dbDataFolder = (Join-path (Split-Path $PSScriptRoot -Parent) 'Database')

$SetupParameters = Get-GITSettings
$SetupParameters | add-member "mainVersion" $version
$SetupParameters | add-member "navIdePath" (Get-NAVClientPath -SetupParameters $SetupParameters)
$SetupParameters | add-member "navServicePath" (Get-NAVServicePath -SetupParameters $SetupParameters)
$SetupParameters | add-member "navRelease" (Get-NAVRelease -MainVersion $version)
$LogPath = (Join-Path $SetupParameters.rootPath "Log\$([GUID]::NewGuid().GUID)")
New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
$branchSettings = @{
    "branchId" = $SetupParameters.branchId; 
    "projectName" = $SetupParameters.projectName; 
    "databaseServer" = $SetupParameters.defaultDatabaseServer; 
    "databaseInstance" = $SetupParameters.defaultDatabaseInstance; 
    "databaseName" = $dbName; 
    "instanceName" = ""; 
    "clientServicesPort" = "7996"; 
    "managementServicesPort" = "7995"}

For ($i=0; $i -le 10; $i++) { Write-Host "" }
$command = "SELECT database_id FROM sys.databases WHERE name = '$dbName'"
$ExistingDbId = Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command $command
if ($ExistingDbId) {
    Write-Host "Removing existing database..."
    $command = "ALTER DATABASE [" + $dbName + "] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [" + $dbName + "]"
    $DropResult = Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command $command
}

Write-Host "Restoring Database $dbName"
$RelocateData = New-Object 'Microsoft.SqlServer.Management.Smo.RelocateFile, Microsoft.SqlServer.SmoExtended, Version=13.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91' -ArgumentList "$($dbName)_Data", (Join-Path $dbDataFolder "$($dbName).mdf")
$RelocateData1 = New-Object 'Microsoft.SqlServer.Management.Smo.RelocateFile, Microsoft.SqlServer.SmoExtended, Version=13.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91' -ArgumentList "$($dbName)_1_Data", (Join-Path $dbDataFolder "$($dbName).ndf")
$RelocateLog = New-Object 'Microsoft.SqlServer.Management.Smo.RelocateFile, Microsoft.SqlServer.SmoExtended, Version=13.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91' -ArgumentList "$($dbName)_Log", (Join-Path $dbDataFolder "$($dbName).ldf")
Restore-SqlDatabase -ServerInstance (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database $dbName -BackupFile $backupFilePath.FullName -RelocateFile @($RelocateData,$RelocateData1,$RelocateLog)

Load-InstanceAdminTools -setupParameters $setupParameters

Write-Host "Upgrading database..."
Invoke-NAVDatabaseConversion -SetupParameters $SetupParameters -BranchSettings $BranchSettings
Write-Host "Compiling Service Objects..."
Compile-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Filter "Type=Table;Id=2000000004..2000000999" -SynchronizeSchemaChanges No 
Write-Host "Creatings Service..."
$SetupParameters | add-member "navVersion" (Get-NAVServerInstance | Where-Object -Property Version -Match ($version.Substring(0, $version.Length - 1) + ".*.0") | Select-Object -First 1).Version
$DefaultInstanceSettings = Get-DefaultInstanceSettings -SetupParameters $SetupParameters -BranchSettings $BranchSettings
$BranchSettings.clientServicesPort = ($DefaultInstanceSettings | Where-Object -Property Key -EQ ClientServicesPort).Value
$BranchSettings.managementServicesPort = ($DefaultInstanceSettings | Where-Object -Property Key -EQ ManagementServicesPort).Value
$params = @{       
    ServerInstance = $dbName 
    DatabaseName = $BranchSettings.databaseName
    DatabaseServer = $BranchSettings.databaseServer
    ManagementServicesPort = ($DefaultInstanceSettings | Where-Object -Property Key -EQ ManagementServicesPort).Value
    ClientServicesPort = ($DefaultInstanceSettings | Where-Object -Property Key -EQ ClientServicesPort).Value
    SOAPServicesPort = ($DefaultInstanceSettings | Where-Object -Property Key -EQ SOAPServicesPort).Value
    ODataServicesPort = ($DefaultInstanceSettings | Where-Object -Property Key -EQ ODataServicesPort).Value }
if ($BranchSettings.databaseInstance -ne "") { $params.DatabaseInstance = $BranchSettings.databaseInstance }
New-NAVServerInstance @params -Force -ServiceAccount NetworkService -ErrorAction Stop
$BranchSettings.instanceName = $dbName
Enable-TcpPortSharingForNAVService -BranchSettings $BranchSettings
Write-Host "Starting Service..."
Set-NAVServerInstance -ServerInstance $dbName -Start -Force 
Write-Host "Syncronizing Database..."
Get-NAVServerInstance -ServerInstance $dbName | Where-Object -Property State -EQ Running | Sync-NAVTenant -Mode ForceSync -Force
Write-Host "Exporting Database $dbName"
Export-NAVData -ServerInstance $dbName -FilePath $navDataFileName -IncludeApplication -IncludeApplicationData -IncludeGlobalData -AllCompanies -Force
Get-NAVServerInstance -ServerInstance $dbName | Remove-NAVServerInstance -Force

Write-Host "Dropping database $dbName"
$command = "ALTER DATABASE [" + $dbName + "] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [" + $dbName + "]"
$DropResult = Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command $command

Write-Host "Creating database $dbName"
$dbDataFile = Join-Path $dbDataFolder ($dbName + "_data.mdf")
$dbLogFile = Join-Path $dbDataFolder ($dbName + "_log.ldf")

$command = "CREATE DATABASE [" + $dbName + "] CONTAINMENT = NONE  ON  PRIMARY "
$command += "( NAME = N'$dbName" + "_Data', FILENAME = N'$dbDataFile' , SIZE = 100MB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%) "
$command += "LOG ON ( NAME = N'$dbName" + "_Log', FILENAME = N'$dbLogFile' , SIZE = 100MB , MAXSIZE = 2048GB , FILEGROWTH = 10%);"
$CreateResult = Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command $command

$command = "ALTER DATABASE [" + $dbName + "] SET COMPATIBILITY_LEVEL = 130;"
$command += "IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')) begin EXEC [" + $dbName + "].[dbo].[sp_fulltext_database] @action = 'enable' end;"
$command += "ALTER DATABASE [" + $dbName + "] SET ANSI_NULL_DEFAULT OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET ANSI_NULLS OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET ANSI_PADDING OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET ANSI_WARNINGS OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET ARITHABORT OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET AUTO_CLOSE OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET AUTO_SHRINK OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET AUTO_UPDATE_STATISTICS ON ;"
$command += "ALTER DATABASE [" + $dbName + "] SET CURSOR_CLOSE_ON_COMMIT OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET CURSOR_DEFAULT  GLOBAL ;"
$command += "ALTER DATABASE [" + $dbName + "] SET CONCAT_NULL_YIELDS_NULL OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET NUMERIC_ROUNDABORT OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET QUOTED_IDENTIFIER OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET RECURSIVE_TRIGGERS OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET DISABLE_BROKER ;"
$command += "ALTER DATABASE [" + $dbName + "] SET AUTO_UPDATE_STATISTICS_ASYNC OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET DATE_CORRELATION_OPTIMIZATION OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET TRUSTWORTHY OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET ALLOW_SNAPSHOT_ISOLATION OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET PARAMETERIZATION SIMPLE ;"
$command += "ALTER DATABASE [" + $dbName + "] SET READ_COMMITTED_SNAPSHOT OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET HONOR_BROKER_PRIORITY OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET RECOVERY SIMPLE ;"
$command += "ALTER DATABASE [" + $dbName + "] SET MULTI_USER ;"
$command += "ALTER DATABASE [" + $dbName + "] SET PAGE_VERIFY CHECKSUM  ;"
$command += "ALTER DATABASE [" + $dbName + "] SET DB_CHAINING OFF ;"
$command += "ALTER DATABASE [" + $dbName + "] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) ;"
$command += "ALTER DATABASE [" + $dbName + "] SET TARGET_RECOVERY_TIME = 0 SECONDS ;"
$command += "ALTER DATABASE [" + $dbName + "] SET DELAYED_DURABILITY = DISABLED ;"
$command += "ALTER DATABASE [" + $dbName + "] SET QUERY_STORE = OFF;"
$UpdateResult = Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command $command

$command = "ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;"
$command += "ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;"
$command += "ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;"
$command += "ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;"
$command += "ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;"
$command += "ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;"
$command += "ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;"
$command += "ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;"
$command += "ALTER DATABASE [" + $dbName + "] SET  READ_WRITE ;"
$UpdateResult = Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database $dbName -Command $command

Write-Host "Importing into Database $dbName"
Import-NAVData -DatabaseServer (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -DatabaseName $dbName -FilePath $navDataFileName -IncludeApplication -IncludeApplicationData -IncludeGlobalData -AllCompanies -Force
Remove-Item -Path $navDataFileName

$command = "DBCC SHRINKFILE(N'$($dbName)_Log', 1) ;"
$UpdateResult = Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database $dbName -Command $command

Write-Host "Creating new Database backup"
Remove-Item -Path $($backupFilePath.FullName) -Force
$command = "BACKUP DATABASE [" + $dbName + "] TO DISK = N'$($backupFilePath.FullName)' WITH COPY_ONLY, COMPRESSION, NOFORMAT, INIT, NAME = N'NAVAPP_QA_MT-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
$BackupResult = Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command $command | Out-Null

Write-Host "Dropping database $dbName "
$command = "ALTER DATABASE [" + $dbName + "] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [" + $dbName + "]"
$DropResult = Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command $command

UnLoad-InstanceAdminTools

