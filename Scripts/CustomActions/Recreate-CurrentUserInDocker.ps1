if ([Bool](Get-Module $SetupParameters.containerHelperModuleName)) {
    Invoke-ScriptInNavContainer -containerName $BranchSettings.dockerContainerName -scriptblock {
        param([string]$NAVUserName)
        Get-NAVServerUser -ServerInstance NAV | Remove-NAVServerUser -ServerInstance NAV -Force
        New-NAVServerUser -ServerInstance NAV -WindowsAccount $NAVUserName
        New-NAVServerUserPermissionSet -ServerInstance NAV -WindowsAccount $NAVUserName -PermissionSetId SUPER
    } -argumentList $env:USERNAME
}