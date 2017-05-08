function Load-AppsTools
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    
    if (!(Get-Module -Name Microsoft.Dynamics.Nav.Apps.Tools)) {      
      Import-Module (Join-Path $SetupParameters.navIdePath 'Microsoft.Dynamics.Nav.Apps.Tools.psd1') -DisableNameChecking -Global -ErrorAction SilentlyContinue
    }
}