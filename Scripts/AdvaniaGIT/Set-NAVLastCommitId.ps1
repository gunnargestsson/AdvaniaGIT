# Florian Dietrich
function Set-NAVLastCommitId
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$LastCommitID
    )
    $command = "SELECT value FROM fn_listextendedproperty(default, default, default, default, default, default, default) WHERE [name] = 'AdvaniaGIT_LastCommitId'"
    $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword 
    if ($result -eq $null) {
        $command = "USE [$($BranchSettings.databaseName)]; EXEC sys.sp_addextendedproperty @name = N'AdvaniaGIT_LastCommitId', @value = N'${LastCommitID}';"
        $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
    } else {
        $command = "USE [$($BranchSettings.databaseName)]; EXEC sys.sp_updateextendedproperty @name = N'AdvaniaGIT_LastCommitId', @value = N'${LastCommitID}';"
        $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
    }
}