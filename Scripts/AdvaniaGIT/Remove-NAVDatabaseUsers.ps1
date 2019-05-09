Function Remove-NAVDatabaseUsers
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $command = "delete from [dbo].[Access Control]"
    $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
    $command = "delete from [dbo].[User]"
    $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
    $command = "delete from [dbo].[User Property]"
    $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
    $command = "select * from sysusers where [islogin] = 1 and uid > 4"
    $users = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
    foreach ($user in $users) {
        if ($user.name -ine "NT AUTHORITY\NETWORK SERVICE") {
            $command = "DROP USER ""$($user.name)"""
            $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
        }
    }
    Write-Host "All users from $($BranchSettings.databaseName) have been removed..."
}



        