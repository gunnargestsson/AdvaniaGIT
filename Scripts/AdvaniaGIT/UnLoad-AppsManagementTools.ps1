function UnLoad-AppsManagementTools
{   
    Get-Module -Name Microsoft.Dynamics.Nav.Apps.Management | Remove-Module -Force
}