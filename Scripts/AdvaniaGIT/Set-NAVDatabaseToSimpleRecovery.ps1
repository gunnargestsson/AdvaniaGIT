function Set-NAVDatabaseToSimpleRecovery
{
    [CmdletBinding()]
    param
    (
        [String]$DatabaseServer,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabaseInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabaseName
    )
    
    if ($DatabaseInstance -gt "") {
        $Server = $DatabaseServer + "\" + $DatabaseInstance
    } else {
        $Server = $DatabaseServer
    }

    # Change Database Recovery Model to Simple and shrink the log file
    $command = "ALTER DATABASE [$DatabaseName] SET RECOVERY SIMPLE WITH NO_WAIT"
    $result = Get-SQLCommandResult -Server $Server -Database $DatabaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
    $command = "SELECT Name FROM sys.database_files WHERE type = 1"
    $logfileName = Get-SQLCommandResult -Server $Server -Database $DatabaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
    $command = "DBCC SHRINKFILE(N'$($logfileName.Name)', 1)"
    $result = Get-SQLCommandResult -Server $Server -Database $DatabaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword

}
