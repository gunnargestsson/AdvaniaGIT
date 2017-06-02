Get-Module -Name AdvaniaGIT | Remove-Module
Import-Module AdvaniaGIT
try {
    Invoke-RemoteCommand -Command 'import-module "C:\Program Files\Microsoft Dynamics NAV\100\Service\Microsoft.Dynamics.Nav.Management.dll"' `
                     -Verbose |
    Invoke-RemoteCommand -Command "Sync-NavTenant -ServerInstance $($env:bamboo_AzureNAV_InstanceName) -Mode Force -Force -Verbose" `
                     -CloseSession `
                     -Verbose
} catch {
    throw $_
}