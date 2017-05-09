# Import all needed modules
Get-Module -Name AdvaniaGIT | Remove-Module
Import-Module AdvaniaGIT -DisableNameChecking | Out-Null

Enable-TcpPortSharingService
UnLoad-InstanceAdminTools

$versions = Get-ChildItem (Join-Path $env:ProgramFiles 'Microsoft Dynamics NAV') | Select-Object -Property Name
foreach ($version in $versions) {
    if ($version.Name -gt 71 -or $version.Name.Length -gt 2) {
        Write-Host "Stopping Services for version $($version.Name.Substring(0,$version.Name.Length - 1))"
        $servicePath = (Join-Path (Join-Path (Join-Path $env:ProgramFiles 'Microsoft Dynamics NAV') $version.Name) 'service')
        $setupParameters = @{navServicePath = $($servicePath)}
        Load-InstanceAdminTools -setupParameters $setupParameters 

        #Stop NAV Server Instances
        Get-NAVServerInstance | Where-Object -Property Version -Match ($version.Name.Substring(0,$version.Name.Length - 1) + ".*.0") | Set-NAVServerInstance -Stop

        UnLoad-InstanceAdminTools
    }
}

