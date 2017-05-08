function Load-InstanceAppTools
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    
    if (!(Get-Module -Name Microsoft.Dynamics.Nav.Apps.Management)) {      
      Import-Module (Join-Path $SetupParameters.navServicePath 'Microsoft.Dynamics.Nav.Apps.Management.psd1') -Global -DisableNameChecking -ErrorAction SilentlyContinue
    }
}