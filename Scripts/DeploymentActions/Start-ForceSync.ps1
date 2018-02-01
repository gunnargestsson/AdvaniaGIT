$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

$WorkFolder = $SetupParameters.WorkFolder
Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer -SetupPath $WorkFolder

Write-Host "Syncronizing changes..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName)
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    Get-NAVTenant -ServerInstance $instanceName | Sync-NAVTenant -Mode ForceSync -Force
} -ArgumentList $DeploymentSettings.instanceName


$Session | Remove-PSSession
