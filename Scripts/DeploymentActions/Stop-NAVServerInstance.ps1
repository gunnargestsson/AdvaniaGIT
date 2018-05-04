$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Write-Host "Stopping NAV instance $($DeploymentSettings.instanceName)..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName)

    Load-InstanceAdminTools -SetupParameters $SetupParameters

    Write-Host "Stopping server instance ${instanceName}..."
    Set-NAVServerInstance -ServerInstance $instanceName -Stop

    UnLoad-InstanceAdminTools

    } -ArgumentList ($DeploymentSettings.instanceName )


$Session | Remove-PSSession