$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName)

    Load-InstanceAdminTools -SetupParameters $SetupParameters
    Write-Host "Executing upgrade codeunits for instance ${instanceName}..."
    Get-NAVTenant -ServerInstance $instanceName | Start-NAVDataUpgrade -Language (Get-Culture).Name -FunctionExecutionMode Parallel -SkipCompanyInitialization -SkipAppVersionCheck -Force -ContinueOnError
    Get-NAVTenant -ServerInstance $instanceName | Get-NAVDataUpgrade -Progress 
    Get-NAVTenant -ServerInstance $instanceName | Get-NAVDataUpgrade -Detailed | Format-Table
    Get-NAVTenant -ServerInstance $instanceName | Stop-NAVDataUpgrade -Force -ErrorAction SilentlyContinue
    UnLoad-InstanceAdminTools

    } -ArgumentList ($DeploymentSettings.instanceName)


$Session | Remove-PSSession