Function Set-NAVDeploymentRemoteInstanceDatabase {
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
        $OriginalDatabase = $Database
        $RemoteConfig = Get-NAVRemoteConfig
        $DBAdmin = Get-NAVPasswordStateUser -PasswordId $RemoteConfig.DBUserPasswordID
        if ($DBAdmin.UserName -gt "") { $Database.DatabaseUserName = $DBAdmin.UserName }
        if ($DBAdmin.Password -gt "") { $Database.DatabasePassword = $DBAdmin.Password }
        if ($DBAdmin.GenericField1 -gt "") { $Database.DatabaseServerName = $DBAdmin.GenericField1 }

        $EncryptionAdmin = Get-NAVPasswordStateUser -PasswordId $RemoteConfig.EncryptionKeyPasswordID
        if ($EncryptionAdmin.Password -gt "") {
            $EncryptionKeyPassword = $EncryptionAdmin.Password
        } else {
            $EncryptionKeyPassword = Get-NAVPassword -Message "Enter password for the encryption key:"
        }

        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        $Database = New-NAVDatabaseDialog -Message "Enter details on database." -Database $Database
        if ($Database.OKPressed -ne 'OK') { return $OriginalDatabase }
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {
                Write-Host "Updating $($RemoteComputer.HostName)..."
                if ($Session.ComputerName -eq $RemoteComputer.FQDN) {
                    $RemoteSession = $Session
                } else {
                    $RemoteSession = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN 
                }        

                Set-NAVRemoteInstanceDatabase -Session $RemoteSession -SelectedInstance $SelectedInstance -Database $Database -EncryptionKeyPath $RemoteComputer.EncryptionKeyPath -EncryptionKeyPassword $EncryptionKeyPassword -InstanceSettings $RemoteComputer.InstanceSettings -RestartServerInstance
                if ($Session.ComputerName -ne $RemoteSession.ComputerName) { Remove-PSSession -Session $RemoteSession }
            }
        }
        Return $Database
    }    
}