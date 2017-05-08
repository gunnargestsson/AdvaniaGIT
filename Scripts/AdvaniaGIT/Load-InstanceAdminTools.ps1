function Load-InstanceAdminTools
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    
    if (!(Get-Module -Name Microsoft.Dynamics.Nav.Management)) {      
      Import-Module (Join-Path $SetupParameters.navServicePath 'Microsoft.Dynamics.Nav.Management.psm1') -DisableNameChecking -Global -ErrorAction SilentlyContinue
    }
}