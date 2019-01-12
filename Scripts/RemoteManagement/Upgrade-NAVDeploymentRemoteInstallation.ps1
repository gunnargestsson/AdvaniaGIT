Function Upgrade-NAVDeploymentRemoteInstallation {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    {         
        $input = Read-Host -Prompt "Please confirm deployment upgrade by typing the deployment name"
        if ($input -ine $DeploymentName) { break }
        $RemoteConfig = Get-NAVRemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        
        $DBAdmin = Get-NAVUserPasswordObject -Usage "DBUserPasswordID"
        if ($DBAdmin.UserName -gt "" -and $DBAdmin.Password -gt "") {
            $DBCredential = New-Object System.Management.Automation.PSCredential($DBAdmin.UserName, (ConvertTo-SecureString $DBAdmin.Password -AsPlainText -Force))
        } else {
            $DBCredential = Get-Credential -Message "Remote Login to FinSql" -ErrorAction Stop
            $DBAdmin.UserName = $DBCredential.UserName
            $DBAdmin.Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($DBCredential.Password))
        }    

        if (!$DBCredential.UserName -or !$DBCredential.Password) {
            Write-Host -ForegroundColor Red "Database Credentials required!"
            break
        }

        $EncryptionAdmin = Get-NAVUserPasswordObject -Usage "EncryptionKeyPasswordID"
        if ($EncryptionAdmin.Password -gt "") {
            $EncryptionKeyPassword = $EncryptionAdmin.Password
        } else {
            $EncryptionKeyPassword = Get-NAVPassword -Message "Enter password for the encryption key:"
        }
        if ($EncryptionKeyPassword -eq "") { break }
        
        
        #Download Latest CU
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            Write-Host "Downloading Latest CU to $($RemoteComputer.HostName)..."
            $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN         
            Download-NAVRemoteLatestCU -Session $Session
            Remove-PSSession $Session
        }
       
        $AllServerInstances = @()
        #Stop Instances
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            Write-Host "Stopping Server Instances on $($RemoteComputer.HostName)..."
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {
                $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN         
                $ServerInstances = Get-NAVRemoteInstances -Session $Session
                Foreach ($ServerInstance in $ServerInstances) {
                    Stop-NAVRemoteInstance -Session $Session -SelectedInstances $ServerInstance
                }
                $AllServerInstances += $ServerInstances
                Remove-PSSession $Session
            }            
        }
       
        #Execute Repair
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            Write-Host "Starting Installation Repair on $($RemoteComputer.HostName)..."
            $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN
            Start-NAVRemoteInstallationRepair -Session $Session 
            Remove-PSSession $Session
        }
        
        #Upgrade Databases
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            Write-Host "Upgrading Databases on $($RemoteComputer.HostName)..."
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {
                $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN         
                $ServerInstances = $AllServerInstances | Where-Object -Property PSComputerName -EQ $RemoteComputer.FQDN
                Upgrade-NAVRemoteApplicationDatabases -Session $Session -ServerInstances $ServerInstances -UserName $DBAdmin.UserName -Password $DBAdmin.Password
                Remove-PSSession $Session
            }            
        }

        #Update Web Service 3 Config
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            Write-Host "Upgrading Web Services 3 Config on $($RemoteComputer.HostName)..."
            $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN
            Upgrade-NAVRemoteWebService3 -Session $Session 
            Remove-PSSession $Session
        }

        #Update Advania Electronic Gateway Config
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            if ($Roles -like "*Client*") {
                Write-Host "Upgrading Advania Electronic Gateway on $($RemoteComputer.HostName)..."            
                $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN         
                Upgrade-NAVRemoteAdvaniaGatewayConfig -Session $Session -FTPServer $SetupParameters.ftpServer -FTPUserName $SetupParameters.ftpUser -FTPPassWord $SetupParameters.ftpPass
                Remove-PSSession $Session
            }            
        }

        #Start Instances
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            Write-Host "Starting Server Instances on $($RemoteComputer.HostName)..."
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {
                $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN         
                $ServerInstances = $AllServerInstances | Where-Object -Property PSComputerName -EQ $RemoteComputer.FQDN
                Foreach ($ServerInstance in $ServerInstances) {
                    Set-NAVRemoteInstanceDefaults -Session $Session -ServerInstance $ServerInstance
                    $Database = New-NAVDatabaseObject -DatabaseName $ServerInstance.DatabaseName -DatabaseServerName $ServerInstance.DatabaseServer -DatabaseInstanceName $ServerInstance.DatabaseInstance -DatabaseUserName $DBAdmin.UserName -DatabasePassword $DBAdmin.Password
                    Set-NAVRemoteInstanceDatabase -Session $Session -SelectedInstance $ServerInstance -Database $Database -EncryptionKeyPath $RemoteComputer.EncryptionKeyPath -EncryptionKeyPassword $EncryptionKeyPassword -InstanceSettings $RemoteComputer.InstanceSettings                    
                    Start-NAVRemoteInstance -Session $Session -SelectedInstances $ServerInstance
                }
                Remove-PSSession $Session
            }            
        }
        
        Write-Host ""
        Write-Host -ForegroundColor Red "Please rebuild ClickOnce and Web Clients from the Deployment Menu!"
        $anyKey = Read-Host "Press enter to continue..."
    }    
}