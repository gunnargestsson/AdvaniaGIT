Load-InstanceAdminTools -setupParameters $setupParameters 
#Import-Module (Join-Path $setupParameters.navServicePath 'Microsoft.Dynamics.Nav.Management.dll') -Scope Local

#Enable the Port Sharing Service
Enable-TcpPortSharingService

#Stop NAV Server Instances
Get-NAVServerInstance | Where-Object -Property Version -Like ($SetupParameters.navVersion.Substring(0,2) + "*.0") | Set-NAVServerInstance -Stop
        
#Update Startup Type and Dependency on NAV Server Instances
Get-NAVServerInstance | Where-Object -Property Version -Like ($SetupParameters.navVersion.Substring(0,2) + "*.0") | foreach {
    $branchSetting = @{instanceName = $($_.ServerInstance)}
    Enable-TcpPortSharingForNAVService -branchSetting $branchSetting
    Enable-DelayedStartForNAVService -branchSetting $branchSetting
}
#Start NAV Server Instances
Write-Host "Starting Services for version $($SetupParameters.navVersion.Substring(0,2))"
Get-NAVServerInstance | Where-Object -Property Version -Like ($SetupParameters.navVersion.Substring(0,2) + "*.0") | Set-NAVServerInstance -Start

UnLoad-InstanceAdminTools

