function UnLoad-ModelTools
{   
    Get-Module -Name Microsoft.Dynamics.Nav.Model.Tools | Remove-Module -Force
}