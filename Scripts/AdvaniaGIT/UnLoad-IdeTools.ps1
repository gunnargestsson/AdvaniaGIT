function UnLoad-IdeTools
{   
    Get-Module -Name Microsoft.Dynamics.Nav.Ide | Remove-Module -Force
}