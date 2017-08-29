# Import all needed modules
Get-Module -Name AdvaniaGIT | Remove-Module
Import-Module AdvaniaGIT -DisableNameChecking | Out-Null

Enable-TcpPortSharingService
UnLoad-InstanceAdminTools

$versions = Get-ChildItem (Join-Path $env:ProgramFiles 'Microsoft Dynamics NAV\*\Service\NavAdminTool.ps1') | Select-Object -Property FullName | Split-Path -Parent | Split-Path -Parent | Split-Path -Leaf
foreach ($version in $versions) {
    Write-Host "Stopping Services for version $($version.Substring(0,$version.Length - 1))"
    $servicePath = (Join-Path (Join-Path (Join-Path $env:ProgramFiles 'Microsoft Dynamics NAV') $version) 'service')
    $setupParameters = @{navServicePath = $($servicePath)}
    Load-InstanceAdminTools -setupParameters $setupParameters 
    #Import-Module (Join-Path $setupParameters.navServicePath 'Microsoft.Dynamics.Nav.Management.dll') -Scope Local

    #Stop NAV Server Instances
    Get-NAVServerInstance | Where-Object -Property Version -Match ($version.Substring(0,$version.Length - 1) + "*.0") | Set-NAVServerInstance -Stop
        
    #Update Startup Type and Dependency on NAV Server Instances
    Get-NAVServerInstance | Where-Object -Property Version -Match ($version.Substring(0,$version.Length - 1) + "*.0") | foreach {
        $branchSetting = @{instanceName = $($_.ServerInstance)}
        Enable-TcpPortSharingForNAVService -branchSetting $branchSetting
        Enable-DelayedStartForNAVService -branchSetting $branchSetting
    }
    #Start NAV Server Instances
    Write-Host "Starting Services for version $($version.Substring(0,$version.Length - 1))"
    Get-NAVServerInstance | Where-Object -Property Version -Match ($version.Substring(0,$version.Length - 1) + "*.0") | Set-NAVServerInstance -Start

    UnLoad-InstanceAdminTools
}

