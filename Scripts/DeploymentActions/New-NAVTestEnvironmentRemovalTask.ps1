$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Write-Host "Scheduling removal of instance and database for $($DeploymentSettings.instanceName) at $((Get-Date).AddDays($DeploymentSettings.daysToLive))..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName,[string]$branchId,[int]$daysToLive,[string]$user,[string]$password)   
    $command = "C:\AdvaniaGIT\Scripts\Start-DeploymentAction.ps1 -ScriptName Remove-NAVTestEnvironmentAsTask.ps1 -DeploymentSettings @{instanceName='$instanceName';branchId='$branchId'}"
    $Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -command `"$command`""
    $Trigger = New-ScheduledTaskTrigger -At (Get-Date).AddDays($daysToLive) -Once     
    Get-ScheduledTask -TaskName "Stop $instanceName" -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false 
    Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName "Stop $instanceName" -Description "Clean test setup" -RunLevel Highest -User $user -Password $password -Force
} -ArgumentList ($DeploymentSettings.instanceName, $DeploymentSettings.branchId, $DeploymentSettings.daysToLive,$VMAdmin.UserName,$VMAdmin.Password)


$Session | Remove-PSSession