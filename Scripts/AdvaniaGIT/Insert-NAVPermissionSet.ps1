function Insert-NAVPermissionSet
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$RoleID,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$RoleName
    )
    $command = "SELECT * FROM [dbo].[Permission Set] WHERE [Role ID] = '$RoleID';"
    $RoleResult = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword 
    if ($RoleResult) {
        if ($RoleName -ne $RoleResult.Name) {
            $command = "UPDATE [dbo].[Permission Set] SET [Name] = '$RoleName' WHERE [Role ID] = '$RoleID';"
            $Result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword 
        }
    } else {
        $command = "INSERT INTO [dbo].[Permission Set] ([Role ID],[Name]) VALUES ('$RoleID', '$RoleName');"
        $Result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword 
    }

}
     