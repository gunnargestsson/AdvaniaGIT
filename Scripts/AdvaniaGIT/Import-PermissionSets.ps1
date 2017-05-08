Function Import-PermissionSets
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $PermissionSets = Get-ChildItem -Path $PermissionSetsPath -ErrorAction SilentlyContinue
    foreach ($PermissionSet in $PermissionSets) {
        [xml]$Xml = Get-Content $PermissionSet.FullName
        Write-Host "Importing Permission Set $($PermissionSet.FullName)"
        Insert-NAVPermissionSet -BranchSettings $BranchSettings -RoleID $Xml.PermissionSets.PermissionSet.RoleID -RoleName $Xml.PermissionSets.PermissionSet.RoleName
        foreach ($Permission in $Xml.PermissionSets.PermissionSet.Permission) {
            Insert-NAVPermission `
                -BranchSettings $BranchSettings `
                -RoleID $Xml.PermissionSets.PermissionSet.RoleID `
                -ObjectType $Permission.ObjectType `
                -ObjectID $Permission.ObjectID `
                -ReadPermission $Permission.ReadPermission `
                -InsertPermission $Permission.InsertPermission `
                -ModifyPermission $Permission.ModifyPermission `
                -DeletePermission $Permission.DeletePermission `
                -ExecutePermission $Permission.ExecutePermission
        }    
    }
}