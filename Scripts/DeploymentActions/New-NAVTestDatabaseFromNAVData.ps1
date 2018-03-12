$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Write-Host "Creating database and restoring data for $($DeploymentSettings.instanceName)..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$databaseName,[string]$branchId)   
        $SetupParameters | Add-Member -MemberType NoteProperty -Name branchId -Value $branchId -Force
        $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
        $navDataFilePath = Join-Path $SetupParameters.BackupPath "$($SetupParameters.navRelease)-${databaseName}.navdata"
        
        $result = Get-SQLCommandResult -Server localhost -Database master -Command "select database_id from sys.databases where name = '${databaseName}'"
        if ($result.database_id) {
            Get-SQLCommandResult -Server localhost -Database master -Command "ALTER DATABASE [${databaseName}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [${databaseName}]" | Out-Null
        }
        
        New-NAVEmptyDatabase -SetupParameters $SetupParameters -DatabaseName $databaseName

        Load-InstanceAdminTools -SetupParameters $SetupParameters
        Import-NAVData -DatabaseServer localhost -DatabaseName $databaseName -FilePath $navDataFilePath -IncludeApplication -IncludeApplicationData -IncludeGlobalData -AllCompanies -Force       
        Write-Host "Restore from ${navDataFilePath} completed..."
        Remove-Item -Path $navDataFilePath -ErrorAction SilentlyContinue

        Write-Host "Verifying database..."
        $result = Get-SQLCommandResult -Server localhost -Database master -Command "select database_id from sys.databases where name = '${databaseName}'"
        if (!$result.database_id) {
            Write-Host Database not created!
            throw
        }

        Write-Host "Adding service user to database..."
        $command = "CREATE USER [NT AUTHORITY\NETWORK SERVICE] FOR LOGIN [NT AUTHORITY\NETWORK SERVICE] WITH DEFAULT_SCHEMA=[dbo]"
        $result = Get-SQLCommandResult -Server localhost -Database $databaseName -Command $command
        $command = "ALTER ROLE [db_owner] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]"
        $result = Get-SQLCommandResult -Server localhost -Database $databaseName -Command $command

        Write-Host "Database ready for use!"

        $BranchSettings.databaseInstance = ''
        $BranchSettings.databaseServer = 'localhost'
        $BranchSettings.databaseName = $databaseName
        $BranchSettings.instanceName = ""
        Update-BranchSettings -BranchSettings $BranchSettings

        UnLoad-InstanceAdminTools
    } -ArgumentList ($DeploymentSettings.instanceName, $DeploymentSettings.branchId)


$Session | Remove-PSSession