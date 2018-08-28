function Get-DefaultDatabaseServer
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    if ($SetupParameters.defaultDatabaseInstance -gt "") {
        $Server = $SetupParameters.defaultDatabaseServer + "\" + $SetupParameters.defaultDatabaseInstance
    } else {
        $Server = $SetupParameters.defaultDatabaseServer
    }
    return $Server
}