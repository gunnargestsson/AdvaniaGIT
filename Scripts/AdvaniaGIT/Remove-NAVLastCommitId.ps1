# Florian Dietrich
function Remove-NAVLastCommitId
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $command = "SELECT value FROM fn_listextendedproperty(default, default, default, default, default, default, default) WHERE [name] = 'AdvaniaGIT_LastCommitId'"
    $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
    if ($result -ne $null) {
        $command = "USE [$($BranchSettings.databaseName)]; EXEC sys.sp_dropextendedproperty @name = N'AdvaniaGIT_LastCommitId';"
        $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
    }
}