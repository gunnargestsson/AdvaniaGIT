function Insert-NAVPermission
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$RoleID,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [int]$ObjectType,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [int]$ObjectID,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [int]$ReadPermission = 0,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [int]$InsertPermission = 0,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [int]$ModifyPermission = 0,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [int]$DeletePermission = 0,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [int]$ExecutePermission = 0
    )
    $command = "SELECT * FROM [dbo].[Permission] WHERE [Role ID] = '$RoleID' AND [Object Type] = $ObjectType AND [Object ID] = $ObjectID;"
    $PermissionResult = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword 
    if ($PermissionResult) {
        if ($ReadPermission -ne $PermissionResult.'Read Permission' -or `
            $InsertPermission -ne $PermissionResult.'Insert Permission' -or `
            $ModifyPermission -ne $PermissionResult.'Modify Permission' -or `
            $DeletePermission -ne $PermissionResult.'Delete Permission' -or `
            $ExecutePermission -ne $PermissionResult.'Execute Permission') 
        {
            $command = "UPDATE [dbo].[Permission] SET [Read Permission] = $ReadPermission"
            $command += ",[Insert Permission] = $InsertPermission"
            $command += ",[Modify Permission] = $ModifyPermission"
            $command += ",[Delete Permission] = $DeletePermission"
            $command += ",[Execute Permission] = $ExecutePermission "
            $command += "WHERE [Role ID] = '$RoleID' AND [Object Type] = $ObjectType AND [Object ID] = $ObjectID;"
            $Result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword 
        }
    } else {
        $command = "INSERT INTO [dbo].[Permission] ([Role ID],[Object Type],[Object ID],[Read Permission],[Insert Permission],[Modify Permission],[Delete Permission],[Execute Permission],[Security Filter]) "
        $command += "VALUES ('$RoleID',$ObjectType,$ObjectID,$ReadPermission,$InsertPermission,$ModifyPermission,$DeletePermission,$ExecutePermission,0x)"
        $Result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword 
    }

}
     