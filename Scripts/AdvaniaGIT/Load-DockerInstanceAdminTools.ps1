function Load-DockerInstanceAdminTools
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )
    
    Invoke-Command -Session $Session -ScriptBlock {
        if (!(Get-Module -Name Microsoft.Dynamics.Nav.Management)) { 
          Import-Module (Join-Path $serviceTierFolder 'Microsoft.Dynamics.Nav.Management.psm1') -DisableNameChecking -Global -ErrorAction SilentlyContinue
        }
    }
}