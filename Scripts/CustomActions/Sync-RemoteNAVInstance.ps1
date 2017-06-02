param (
    $RemoteNavAdminModulePath
)
Get-Module -Name AdvaniaGIT | Remove-Module
Import-Module AdvaniaGIT
try {
    Invoke-RemoteCommand -Command "import-module '$RemoteNavAdminModulePath'" `
                     -Verbose |
    Invoke-RemoteCommand -Command "Sync-NavTenant -ServerInstance $($env:bamboo_AzureNAV_InstanceName) -Mode Force -Force -Verbose" `
                     -CloseSession `
                     -Verbose
} catch {
    throw $_
}