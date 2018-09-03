$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Write-Host "Dismounting NAV Database $($DeploymentSettings.databaseToMount)..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName,[string]$tenantId)

    Load-InstanceAdminTools -SetupParameters $SetupParameters
    
    $Tenant = Get-NAVTenant -ServerInstance $instanceName | Where-Object -Property Id -EQ $tenantId
    if ($Tenant) {
        Write-Host "Dismounting tenant ${tenantId}..."
        Dismount-NAVTenant -ServerInstance $instanceName -Tenant $tenantId -Force
    } else {
        Write-Host "Tenant ${tenantId} not mounted, continuing..."
    }

    UnLoad-InstanceAdminTools

    } -ArgumentList ($DeploymentSettings.instanceName, $DeploymentSettings.tenantId)


$Session | Remove-PSSession