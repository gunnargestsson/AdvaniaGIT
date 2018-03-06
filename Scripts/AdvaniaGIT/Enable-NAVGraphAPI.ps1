Function Enable-NAVGraphAPI
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$RestartServiceTier
    )
    
    Invoke-Command -Session $Session -ScriptBlock {
        param([Switch]$RestartServiceTier)
        if (!(Get-Module -Name Microsoft.Dynamics.Nav.Management)) { 
          Import-Module (Join-Path $serviceTierFolder 'Microsoft.Dynamics.Nav.Management.psm1') -DisableNameChecking -Global -ErrorAction SilentlyContinue
        }
        $ServerInstance = (Get-NAVServerInstance).ServerInstance.Split('$')[1]
        Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName ApiServicesEnabled -KeyValue true
        if ($RestartServiceTier) {
            Set-NAVServerInstance -ServerInstance $ServerInstance -Restart
        }
    } -ArgumentList $RestartServiceTier
}