function UnLoad-InstanceAdminTools
{   
    Get-Module -Name Microsoft.Dynamics.Nav.Management | Remove-Module -Force
}