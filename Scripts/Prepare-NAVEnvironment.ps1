# Import all needed modules
Get-Module -Name AdvaniaGIT | Remove-Module
Import-Module AdvaniaGIT -DisableNameChecking | Out-Null

Enable-TcpPortSharingService
UnLoad-InstanceAdminTools

$setupParameters | Add-Member -MemberType NoteProperty -Name navServicePath -Value ""
$setupParameters | Add-Member -MemberType NoteProperty -Name navIdePath -Value ""
$versions = Get-ChildItem (Join-Path $env:ProgramFiles 'Microsoft Dynamics NAV\*\Service\Microsoft.Dynamics.Nav.Management.psm1') | Select-Object -Property FullName | Split-Path -Parent | Split-Path -Parent | Split-Path -Leaf
foreach ($version in $versions) {
    Write-Host "Stopping Services for version $($version.Substring(0,$version.Length - 1))"
    $setupParameters.navServicePath  = (Join-Path (Join-Path (Join-Path $env:ProgramFiles 'Microsoft Dynamics NAV') $version) 'service')
    $setupParameters.navIdePath = (Join-Path (Join-Path (Join-Path ${env:ProgramFiles(x86)} 'Microsoft Dynamics NAV') $version) 'RoleTailored Client')
    Load-InstanceAdminTools -setupParameters $setupParameters 

    #Stop NAV Server Instances
    Get-NAVServerInstance | Where-Object -Property Version -Match ($version.Substring(0,$version.Length - 1) + "*.0") | Set-NAVServerInstance -Stop
        
    #Update Startup Type and Dependency on NAV Server Instances
    Get-NAVServerInstance | Where-Object -Property Version -Match ($version.Substring(0,$version.Length - 1) + "*.0") | foreach {
        $branchSetting = @{instanceName = $($_.ServerInstance)}
        Enable-TcpPortSharingForNAVService -branchSetting $branchSetting
        Enable-DelayedStartForNAVService -branchSetting $branchSetting
    }
    #Update Advania.Electronic.Gateway.Config
    if ($SetupParameters.ftpServer -gt "") {
        try { Get-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpFilePath "Advania.Electronic.Gateway.Config" -LocalFilePath (Join-Path $setupParameters.navServicePath "Advania.Electronic.Gateway.Config") }
        catch { }
    }

    #Update Service Configuration
    Enable-NAVWebServices3 -SetupParameters $SetupParameters

    #Start NAV Server Instances
    Write-Host "Starting Services for version $($version.Substring(0,$version.Length - 1))"
    Get-NAVServerInstance | Where-Object -Property Version -Match ($version.Substring(0,$version.Length - 1) + "*.0") | Set-NAVServerInstance -Start

    UnLoad-InstanceAdminTools
}

