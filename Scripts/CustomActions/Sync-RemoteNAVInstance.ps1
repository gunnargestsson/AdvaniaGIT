<#
$SetupParameters
    navServicePath = path to NAV service, default C:\Program Files\Microsoft Dynamics NAV\100\Service
    RemoteInstanceName = NAV Instance Name on Remote Server
    RemoteServerName = FDQN for the Remote Server.  Connection made via secure powershell port 5986
    RemoteUserName = Administrator user on the Remote Server
    RemotePassword = Plain Text password for administration user on Remote Server

#>
$RemoteNavAdminModulePath = Join-Path $SetupParameters.navServicePath "Microsoft.Dynamics.Nav.Management.dll"

try {
    Invoke-RemoteCommand -Command "import-module '$RemoteNavAdminModulePath'" -VMAdminUserName $SetupParameters.RemoteUserName -VMAdminPassword $SetupParameters.RemotePassword -VMURL $SetupParameters.RemoteServerName |
    Invoke-RemoteCommand -Command "Sync-NavTenant -ServerInstance $($SetupParameters.RemoteInstanceName) -Mode Force -Force -Verbose" -CloseSession 
} catch {
    throw $_
}