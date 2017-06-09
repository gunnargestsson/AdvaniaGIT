Load-InstanceAdminTools -setupParameters $setupParameters 
Write-Host "Stopping Services for version $($SetupParameters.navVersion.Substring(0,2))"
Get-NAVServerInstance | Where-Object -Property Version -Match ($SetupParameters.navVersion.Substring(0,2) + ".*.0") | Set-NAVServerInstance -Stop
UnLoad-InstanceAdminTools