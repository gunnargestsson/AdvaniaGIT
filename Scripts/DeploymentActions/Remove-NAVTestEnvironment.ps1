$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Write-Host "Remove instance and database for $($DeploymentSettings.instanceName)..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName,[string]$branchId)   
        $SetupParameters | Add-Member -MemberType NoteProperty -Name branchId -Value $branchId -Force
        $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
        if ($BranchSettings.instanceName -ieq $instanceName) {
            Load-InstanceAdminTools -SetupParameters $SetupParameters
            Remove-NAVEnvironment -BranchSettings $BranchSettings
            UnLoad-InstanceAdminTools
        }
    } -ArgumentList ($DeploymentSettings.instanceName, $DeploymentSettings.branchId)


$Session | Remove-PSSession