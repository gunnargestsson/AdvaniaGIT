function UnLoad-AppsTools
{   
    Get-Module -Name Microsoft.Dynamics.Nav.Apps.Tools | Remove-Module -Force
}