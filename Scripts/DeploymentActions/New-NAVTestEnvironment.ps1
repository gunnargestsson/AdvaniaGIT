$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Write-Host "Creating instance $($DeploymentSettings.instanceName)..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName,[string]$branchId)   
        $SetupParameters | Add-Member -MemberType NoteProperty -Name branchId -Value $branchId -Force
        $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
        $BranchSettings.databaseInstance = ''
        $BranchSettings.databaseServer = 'localhost'
        $BranchSettings.databaseName = $instanceName
        $BranchSettings.instanceName = ""

        Load-InstanceAdminTools -SetupParameters $SetupParameters
        Write-Host "Simplifying Database..."
        Set-NAVDatabaseToSimpleRecovery -DatabaseServer $BranchSettings.databaseServer -DatabaseInstance $BranchSettings.databaseInstance -DatabaseName $BranchSettings.databaseName

        Write-Host "Creating Service..."
        $DefaultInstanceSettings = Get-DefaultInstanceSettings -SetupParameters $SetupParameters -BranchSettings $BranchSettings
        $BranchSettings.clientServicesPort = $DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ClientServicesPort']").Attributes["value"].Value
        $BranchSettings.managementServicesPort = $DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ManagementServicesPort']").Attributes["value"].Value
        $params = @{       
          ServerInstance = $instanceName 
          DatabaseName = $BranchSettings.databaseName
          DatabaseServer = $BranchSettings.databaseServer
          ManagementServicesPort = $DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ManagementServicesPort']").Attributes["value"].Value
          ClientServicesPort = $DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ClientServicesPort']").Attributes["value"].Value
          SOAPServicesPort = $DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='SOAPServicesPort']").Attributes["value"].Value
          ODataServicesPort = $DefaultInstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ODataServicesPort']").Attributes["value"].Value          
        }
        if ($BranchSettings.databaseInstance -ne "") { $params.DatabaseInstance = $BranchSettings.databaseInstance }
        New-NAVServerInstance @params -Force -ServiceAccount NetworkService -ErrorAction Stop
        $BranchSettings.instanceName = $instanceName
        Enable-DelayedStartForNAVService -BranchSettings $BranchSettings
        Enable-TcpPortSharingForNAVService -BranchSettings $BranchSettings
        Write-Host "Starting Service..."
        Set-NAVServerInstance -ServerInstance $instanceName -Start -Force 
        Write-Host "Syncronizing Database..."
        Get-NAVServerInstance -ServerInstance $instanceName | Where-Object -Property State -EQ Running | Sync-NAVTenant -Mode ForceSync -Force
        Update-BranchSettings -BranchSettings $BranchSettings
        Write-Host "Environment build completed..."

        UnLoad-InstanceAdminTools
    } -ArgumentList ($DeploymentSettings.instanceName, $DeploymentSettings.branchId)


$Session | Remove-PSSession