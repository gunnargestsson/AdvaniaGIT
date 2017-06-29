Function Set-NAVRemoteInstanceDatabase {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Database,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$EncryptionKeyPath,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$EncryptionKeyPassword,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$InstanceSettings
    )
    PROCESS 
    {
        Invoke-Command -Session $Session -ScriptBlock `
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
                Write-Host "Updating Settings..."
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
                    if (Test-Path $EncryptionKeyPath) {
                        $KeyPath = Get-Item -Path $EncryptionKeyPath
                        Write-Host "Importing Encryption Key $($KeyPath.FullName) to $ServerInstance and database $($Database.DatabaseServerName) $($Database.DatabaseName) as user $($DatabaseCredentials.UserName).."
                        $Password = (ConvertTo-SecureString -AsPlainText -String $EncryptionKeyPassword -Force)                                                                                                                      
                        Import-NAVEncryptionKey -KeyPath $KeyPath.FullName -ServerInstance $ServerInstance -ApplicationDatabaseServer $Database.DatabaseServerName -ApplicationDatabaseCredentials $DatabaseCredentials -ApplicationDatabaseName $Database.DatabaseName -Password $Password -Force
                    }

                    Write-Host "Setting Database Credentials for service $ServerInstance..."
                    Set-NAVServerConfiguration -ServerInstance $ServerInstance -DatabaseCredentials $DatabaseCredentials -Force
                        
                }
                $branchSetting = @{instanceName = $($ServerInstance)}
                Enable-TcpPortSharingForNAVService -branchSetting $branchSetting
                Enable-DelayedStartForNAVService -branchSetting $branchSetting
                Write-Host "Starting Instance $ServerInstance ..."
                Set-NAVServerInstance -ServerInstance $ServerInstance -Start
                Get-NAVTenant -ServerInstance $ServerInstance | Sync-NAVTenant -Mode Sync -Force
                UnLoad-InstanceAdminTools
            } -ArgumentList (
                $SelectedInstance.ServerInstance,  
                $Database,
                $EncryptionKeyPath,
                $EncryptionKeyPassword,
                $InstanceSettings)
    }
}