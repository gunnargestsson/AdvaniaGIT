function Load-AppsManagementTools
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    
    if (!(Get-Module -Name Microsoft.Dynamics.Nav.Apps.Management)) {      
      Import-Module (Join-Path $SetupParameters.navIdePath 'Microsoft.Dynamics.Nav.Apps.Management.psd1') -DisableNameChecking -Global -ErrorAction SilentlyContinue
    }
}