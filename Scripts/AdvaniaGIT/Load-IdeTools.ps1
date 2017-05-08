function Load-IdeTools
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    
    if (!(Get-Module -Name Microsoft.Dynamics.Nav.Ide)) {      
      Import-Module (Join-Path $SetupParameters.navIdePath 'Microsoft.Dynamics.Nav.Ide.psm1') -DisableNameChecking -Global -ErrorAction SilentlyContinue
    }
}