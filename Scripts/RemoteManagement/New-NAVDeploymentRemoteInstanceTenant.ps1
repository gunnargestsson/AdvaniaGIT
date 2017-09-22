Function New-NAVDeploymentRemoteInstanceTenant {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    { 
        $RemoteConfig = Get-NAVRemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName

        $Database = New-NAVDatabaseObject 
        $DBAdmin = Get-NAVPasswordStateUser -PasswordId $RemoteConfig.DBUserPasswordID
        if ($DBAdmin.UserName -gt "") { $Database.DatabaseUserName = $DBAdmin.UserName }
        if ($DBAdmin.Password -gt "") { $Database.DatabasePassword = $DBAdmin.Password }
        if ($DBAdmin.GenericField1 -gt "") { $Database.DatabaseServerName = $DBAdmin.GenericField1 }

        #Ask Database Settings
        $Database = New-NAVDatabaseDialog -Message "Enter details on database." -Database $Database
        if ($Database.OKPressed -ne 'OK') { break }

        #Ask for Tenant Settings $SelectedTenant
        $TenantSettings = Get-NAVRemoteInstanceDefaultTenant -SelectedInstance $SelectedInstance 
        $TenantSettings = Combine-Settings $TenantSettings (New-NAVTenantSettingsObject)
        $SelectedTenant = New-NAVTenantSettingsDialog -Message "Edit New Tenant Settings" -TenantSettings $TenantSettings
        if ($SelectedTenant.OKPressed -ne 'OK') { break }
        if ($SelectedTenant.CustomerName -eq "") { 
            Write-Host -ForegroundColor Red "Customer Name missing!"
            break
        }

        if ($SelectedTenant.LicenseNo -gt "" ) {
            $FtpFileName = "license/$($SelectedTenant.LicenseNo).flf"
            $LocalFileName = Join-Path $env:TEMP "$($SelectedTenant.LicenseNo).flf"
            try { Get-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpFilePath $FtpFileName -LocalFilePath $LocalFileName }
            catch { Write-Host "Unable to download license from $LocalFileName !" }
        } 
        $hostNo = 1
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            Write-Host "Updating $($RemoteComputer.HostName)..."
            $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN         
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {
                Mount-NAVRemoteInstanceTenant -Session $Session -SelectedTenant $SelectedTenant -Database $Database
                Start-NAVRemoteInstanceTenantSync -Session $Session -SelectedTenant $SelectedTenant
                $RemoteTenantSettings = Set-NAVRemoteInstanceTenantSettings -Session $Session -SelectedTenant $SelectedTenant 
                break
            }
            Remove-PSSession $Session
        }
        $anyKey = Read-Host "Press enter to continue..."
    }    
}