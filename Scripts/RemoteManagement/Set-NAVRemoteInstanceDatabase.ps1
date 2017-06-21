Function Set-NAVRemoteInstanceDatabase {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Database
    )
    PROCESS 
    {
        $RemoteConfig = Get-RemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        $Database = New-DatabaseDialog -Message "Enter details on database." -Database $Database
        $EncryptionKeyPassword = Get-Password -Message "Enter password for the encryption key:"
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            Write-Host "Updating $($RemoteComputer.HostName)..."
            if ($Session.ComputerName -eq $RemoteComputer.FQDN) {
                $RemoteSession = $Session
            } else {
                $RemoteSession = Create-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN 
            }        
            Invoke-Command -Session $RemoteSession -ScriptBlock `
                {
                    param(
                        [String]$ServerInstance,
                        [PSObject]$Database,
                        [String]$EncryptionKeyPath,
                        [String]$EncryptionKeyPassword,
                        [PSObject]$InstanceSettings)
                    Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                    Load-InstanceAdminTools -SetupParameters $SetupParameters
                    Write-Host "Stopping Instance $ServerInstance..."
                    Set-NAVServerInstance -ServerInstance $ServerInstance -Stop
                    Write-Host "Update Settings..."
                    Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName DatabaseName -KeyValue $Database.DatabaseName
                    Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName DatabaseServer -KeyValue $Database.DatabaseServerName
                    Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName DatabaseInstance -KeyValue $Database.DatabaseInstanceName

                    $Properties = Foreach ($InstanceSetting in $InstanceSettings) { Get-Member -InputObject $InstanceSetting -MemberType NoteProperty}
                    Foreach ($Property in $Properties.Name) {
                        $KeyValue = $ExecutionContext.InvokeCommand.ExpandString($InstanceSettings.$($Property))                        
                        Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName $Property -KeyValue $KeyValue
                    }

                    if ($Database.DatabaseUserName -eq "") {
                        Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName DatabaseUserName -KeyValue ""
                    } else {
                        Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName DatabaseUserName -KeyValue $Database.DatabaseUserName                        
                        $DatabaseCredentials = New-Object System.Management.Automation.PSCredential($Database.DatabaseUserName, (ConvertTo-SecureString $Database.DatabasePassword -AsPlainText -Force))
                        Write-Host "Setting Database Credentials for service $ServerInstance..."
                        Set-NAVServerConfiguration -ServerInstance $ServerInstance -DatabaseCredentials $DatabaseCredentials -Force
                        
                        if (Test-Path $EncryptionKeyPath) {
                            $KeyPath = Get-Item -Path $EncryptionKeyPath
                            Write-Host "Importing Encryption Key $($KeyPath.FullName) to $ServerInstance and database $($Database.DatabaseServerName) $($Database.DatabaseName) as user $($DatabaseCredentials.UserName).."
                            $Password = (ConvertTo-SecureString -AsPlainText -String $EncryptionKeyPassword -Force)                                                                                                                      
                            Import-NAVEncryptionKey -KeyPath $KeyPath.FullName -ServerInstance $ServerInstance -ApplicationDatabaseServer $Database.DatabaseServerName -ApplicationDatabaseCredentials $DatabaseCredentials -ApplicationDatabaseName $Database.DatabaseName -Password $Password -Force
                        }
                        
                    }
                    $branchSetting = @{instanceName = $($ServerInstance)}
                    Enable-TcpPortSharingForNAVService -branchSetting $branchSetting
                    Enable-DelayedStartForNAVService -branchSetting $branchSetting
                    Write-Host "Starting Instance $ServerInstance ..."
                    Set-NAVServerInstance -ServerInstance $ServerInstance -Start
                    UnLoad-InstanceAdminTools
                } -ArgumentList (
                    $SelectedInstance.ServerInstance,  
                    $Database,
                    $RemoteComputer.EncryptionKeyPath,
                    $EncryptionKeyPassword,
                    $RemoteComputer.InstanceSettings )        
        }
        Return $Database
    }    
}