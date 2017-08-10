function Restore-NAVBackup
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$BackupFilePath,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabaseServer,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabaseInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabaseName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabasePath
    )
    $DataFilesDestinationPath = Join-Path $DatabasePath ($DatabaseName + '_data.mdf')
    $LogFilesDestinationPath = Join-Path $DatabasePath ($DatabaseName + '_log.ldf')
    $ServiceAccount = "NT AUTHORITY\NETWORK SERVICE"

    $params = @{ 
        FilePath = $BackupFilePath 
        DatabaseServer = $DatabaseServer 
        DatabaseName = $DatabaseName 
        ServiceAccount = $ServiceAccount 
        DataFilesDestinationPath = $DataFilesDestinationPath 
        LogFilesDestinationPath = $LogFilesDestinationPath 
        Timeout = 360 }
    if ($DatabaseInstance -ne "") { $params.DatabaseInstance = $DatabaseInstance }
    New-NAVDatabase @params -Force | Out-Null
    
    if ($DatabaseInstance -gt "") {
        $Server = $DatabaseServer + "\" + $DatabaseInstance
    } else {
        $Server = $DatabaseServer
    }

    # Change Database Recovery Model to Simple and shrink the log file
    $command = "ALTER DATABASE [$DatabaseName] SET RECOVERY SIMPLE WITH NO_WAIT"
    $result = Get-SQLCommandResult -Server $Server -Database $DatabaseName -Command $command
    $command = "SELECT Name FROM sys.database_files WHERE type = 1"
    $logfileName = Get-SQLCommandResult -Server $Server -Database $DatabaseName -Command $command
    $command = "DBCC SHRINKFILE(N'$($logfileName.Name)', 1)"
    $result = Get-SQLCommandResult -Server $Server -Database $DatabaseName -Command $command

}
