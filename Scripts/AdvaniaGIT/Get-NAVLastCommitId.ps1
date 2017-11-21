# Florian Dietrich
function Get-NAVLastCommitId
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $command = "SELECT value FROM fn_listextendedproperty(default, default, default, default, default, default, default) WHERE [name] = 'AdvaniaGIT_LastCommitId'"
    $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command 
    if ($result -ne $null) {
        return $result.Value
    }
}