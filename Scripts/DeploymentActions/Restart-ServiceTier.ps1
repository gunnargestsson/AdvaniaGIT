$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer -SetupPath $WorkFolder

Write-Host "Restarting Server Intance $($DeploymentSettings.instanceName)..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName)
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    Set-NAVServerInstance -ServerInstance $instanceName -Restart
} -ArgumentList $DeploymentSettings.instanceName


$Session | Remove-PSSession
