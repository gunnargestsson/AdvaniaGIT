Function New-NAVEmptyDatabase
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabaseName
    )

    $command = "SELECT DATABASEPROPERTYEX('master', 'Collation');"
    $CollationResult = Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
    $selectedCollation = Read-Host -Prompt "Select Database Collation (default=$($CollationResult.Column1))" 
    if ($selectedCollation -eq "") { $selectedCollation = $CollationResult.Column1 }

    Write-Host "Creating database $DatabaseName"
    $dbDataFile = Join-Path $SetupParameters.DatabasePath ($DatabaseName + "_data.mdf")
    $dbLogFile = Join-Path $SetupParameters.DatabasePath ($DatabaseName + "_log.ldf")

    $command = "CREATE DATABASE [" + $DatabaseName + "] CONTAINMENT = NONE  ON  PRIMARY "
    $command += "( NAME = N'$DatabaseName" + "_Data', FILENAME = N'$dbDataFile' , SIZE = 100MB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%) "
    $command += "LOG ON ( NAME = N'$DatabaseName" + "_Log', FILENAME = N'$dbLogFile' , SIZE = 100MB , MAXSIZE = 2048GB , FILEGROWTH = 10%) "
    $command += "COLLATE ${selectedCollation};"
    $CreateResult = Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword

    $command = "ALTER DATABASE [" + $DatabaseName + "] SET COMPATIBILITY_LEVEL = 130;"
    $command += "IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')) begin EXEC [" + $DatabaseName + "].[dbo].[sp_fulltext_database] @action = 'enable' end;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET ANSI_NULL_DEFAULT OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET ANSI_NULLS OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET ANSI_PADDING OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET ANSI_WARNINGS OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET ARITHABORT OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET AUTO_CLOSE OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET AUTO_SHRINK OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET AUTO_UPDATE_STATISTICS ON ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET CURSOR_CLOSE_ON_COMMIT OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET CURSOR_DEFAULT  GLOBAL ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET CONCAT_NULL_YIELDS_NULL OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET NUMERIC_ROUNDABORT OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET QUOTED_IDENTIFIER OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET RECURSIVE_TRIGGERS OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET DISABLE_BROKER ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET AUTO_UPDATE_STATISTICS_ASYNC OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET DATE_CORRELATION_OPTIMIZATION OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET TRUSTWORTHY OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET ALLOW_SNAPSHOT_ISOLATION OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET PARAMETERIZATION SIMPLE ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET READ_COMMITTED_SNAPSHOT OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET HONOR_BROKER_PRIORITY OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET RECOVERY SIMPLE ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET MULTI_USER ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET PAGE_VERIFY CHECKSUM  ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET DB_CHAINING OFF ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET TARGET_RECOVERY_TIME = 0 SECONDS ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET DELAYED_DURABILITY = DISABLED ;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET QUERY_STORE = OFF;"
    $UpdateResult = Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword

    $command = "ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;"
    $command += "ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;"
    $command += "ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;"
    $command += "ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;"
    $command += "ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;"
    $command += "ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;"
    $command += "ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;"
    $command += "ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;"
    $command += "ALTER DATABASE [" + $DatabaseName + "] SET  READ_WRITE ;"
    $UpdateResult = Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database $DatabaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
}