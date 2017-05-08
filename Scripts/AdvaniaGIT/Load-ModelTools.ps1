function Load-ModelTools
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    
    if (!(Get-Module -Name Microsoft.Dynamics.Nav.Model.Tools)) {      
      Import-Module (Join-Path $SetupParameters.navIdePath 'Microsoft.Dynamics.Nav.Model.Tools.psd1') -DisableNameChecking -Global -ErrorAction SilentlyContinue
    }
}