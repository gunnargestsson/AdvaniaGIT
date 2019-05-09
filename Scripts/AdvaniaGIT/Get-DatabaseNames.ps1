function Get-DatabaseNames
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    if ($SetupParameters.defaultDatabaseInstance -eq "") {
        $DatabaseServer = $SetupParameters.defaultDatabaseServer 
    } else {
        $DatabaseServer = "$($SetupParameters.defaultDatabaseServer)\$($SetupParameters.defaultDatabaseInstance)"
    }
    $command = "SELECT [Name] FROM sys.databases WHERE database_id > 4"
    $DatabaseNames = Get-SQLCommandResult -Server $DatabaseServer -Database master -Command $command -ForceDataset -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword    
    Return $DatabaseNames
}