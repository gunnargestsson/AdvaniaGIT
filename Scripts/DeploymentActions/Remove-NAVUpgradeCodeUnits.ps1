$DbAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.SqlServerPid
$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Write-Host "Removing Upgrade Codeunits from $($DeploymentSettings.instanceName)..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName,[string]$Username,[String]$Password)

    Load-InstanceAdminTools -SetupParameters $SetupParameters
    $InstanceSettings = Get-NAVServerConfiguration -ServerInstance $instanceName -AsXml
    $databaseServer = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='DatabaseServer']").Attributes["value"].Value
    $databaseName = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='DatabaseName']").Attributes["value"].Value
    UnLoad-InstanceAdminTools

    $command = "SELECT [Object ID] FROM [dbo].[Object Metadata] WHERE [Object Type] = 5 AND [Object Subtype] = 'Upgrade'"
    $result = Get-SQLCommandResult -Server $databaseServer -Database $databaseName -Command $command -Username $Username -Password $Password
    foreach ($id in $result.'Object ID') {
        $command = "DELETE FROM [dbo].[Object] WHERE [Type] = '5' AND [ID] = '${id}'"
        $result = Get-SQLCommandResult -Server $databaseServer -Database $databaseName -Command $command -Username $Username -Password $Password
    }
    

    } -ArgumentList ($DeploymentSettings.instanceName, $DbAdmin.UserName, $DbAdmin.Password )


$Session | Remove-PSSession