function Get-DatabaseServer
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    if ($BranchSettings.databaseInstance -gt "") {
        $Server = $BranchSettings.databaseServer + "\\" + $BranchSettings.databaseInstance
    } else {
        $Server = $BranchSettings.databaseServer
    }
    return $Server
}