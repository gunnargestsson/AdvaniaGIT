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

#Update Advania.Electronic.Gateway.Config
if ($SetupParameters.ftpServer -gt "") {
    $ftpDirectory = Get-FtpDirectory -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -Directory "Advania.Electronic.Gateway.Config"
    if ($ftpDirectory -imatch "Advania.Electronic.Gateway.Config") {
        Get-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpFilePath "Advania.Electronic.Gateway.Config" -LocalFilePath (Join-Path $setupParameters.navServicePath "Advania.Electronic.Gateway.Config") 
    }
}

#Update Service Configuration
Enable-NAVWebServices3 -SetupParameters $SetupParameters

#Start NAV Server Instances
Write-Host "Starting Services for version $($SetupParameters.navVersion.Substring(0,2))"
Get-NAVServerInstance | Where-Object -Property Version -Like ($SetupParameters.navVersion.Substring(0,2) + "*.0") | Set-NAVServerInstance -Start

UnLoad-InstanceAdminTools

