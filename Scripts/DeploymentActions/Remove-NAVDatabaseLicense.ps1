$DbAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.SqlServerPid
$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer -SetupPath $WorkFolder

Write-Host "Removing Database License on remote server..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$branchId,[string]$instanceName,[string]$Username,[string]$Password)
    Write-Host "Updating branch settings for ${branchId} as $($DbAdmin.UserName)..."
    $SetupParameters | Add-Member -MemberType NoteProperty -Name branchId -Value $branchId
    $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
    $BranchSettings.instanceName = $instanceName
    $InstanceSettings = Get-InstanceSettings -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    $BranchSettings.databaseServer = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='DatabaseServer']").Attributes["value"].Value
    $BranchSettings.databaseName = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='DatabaseName']").Attributes["value"].Value
    $BranchSettings.clientServicesPort = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ClientServicesPort']").Attributes["value"].Value
    $BranchSettings.managementServicesPort = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ManagementServicesPort']").Attributes["value"].Value 
    $command = "select name from sys.tables where name = '`$ndo`$dbproperty'"
    $tableName = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Username $Username -Password $Password -Command $command -ForceDataset
    if ($tableName) {
        Write-Host "Removing license from $($tablename.name)..."
        $command = "update [$($tablename.name)] set [license] = null"
        Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Username $Username -Password $Password -Command $command | Out-Null
    }

} -ArgumentList ($DeploymentSettings.branchId, $DeploymentSettings.instanceName, $DbAdmin.UserName, $DbAdmin.Password)


$Session | Remove-PSSession
