Function Import-PermissionSets
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $PermissionSets = Get-ChildItem -Path $SetupParameters.PermissionSetsPath -ErrorAction SilentlyContinue
    foreach ($PermissionSet in $PermissionSets) {
        [xml]$Xml = Get-Content $PermissionSet.FullName
        Write-Host "Importing Permission Set $($PermissionSet.FullName)"
        foreach ($Sets in $Xml.PermissionSets) {
            foreach ($Set in $Sets.PermissionSet) {
                Insert-NAVPermissionSet -BranchSettings $BranchSettings -RoleID $Set.RoleID -RoleName $Set.RoleName
                foreach ($Permission in $Set.Permission) {
                    Insert-NAVPermission `
                        -BranchSettings $BranchSettings `
                        -RoleID $Set.RoleID `
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
    }
}
