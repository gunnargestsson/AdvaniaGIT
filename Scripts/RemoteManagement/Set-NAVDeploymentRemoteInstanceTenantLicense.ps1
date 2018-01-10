Function Set-NAVDeploymentRemoteInstanceTenantLicense {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$ApplicationLicense
    )
    PROCESS 
    {
        if ($SelectedTenant.LicenseNo -eq "") {
            Write-Host -ForegroundColor Red "License Number is not defined in Tenant Settings, removing license from database!"
            $UserName = $Credential.UserName
            $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password))
            $Result = Get-SQLCommandResult -Server $SelectedTenant.DatabaseServer -Database $SelectedTenant.DatabaseName -Command "UPDATE [dbo].[`$ndo`$dbproperty] SET [license] = null" -Username $UserName -Password $Password -ErrorAction SilentlyContinue
            $Result = Get-SQLCommandResult -Server $SelectedTenant.DatabaseServer -Database $SelectedTenant.DatabaseName -Command "UPDATE [dbo].[`$ndo`$tenantproperty] SET [license] = null" -Username $UserName -Password $Password -ErrorAction SilentlyContinue
            Write-Host -ForegroundColor DarkGreen "Restart Service Instance for changes to take effect"
            break
        }
        $FtpFileName = "license/$($SelectedTenant.LicenseNo).flf"
        $LocalFileName = Join-Path $env:TEMP "$($SelectedTenant.LicenseNo).flf"
        Remove-Item -Path $LocalFileName -Force -ErrorAction SilentlyContinue
        try { Get-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpFilePath $FtpFileName -LocalFilePath $LocalFileName }
        catch {}
        if (!(Test-Path $LocalFileName)) {
            Write-Host -ForegroundColor Red "Unable to download the License File from $($SetupParameters.ftpServer)!"
            $anyKey = Read-Host "Press enter to continue..."
            break
        }
        $LicenseData = [Byte[]] (Get-Content -Path $LocalFileName -Encoding Byte)
        Remove-Item -Path $LocalFileName -Force -ErrorAction SilentlyContinue

        $RemoteConfig = Get-NAVRemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {
                Write-Host "Updating $($RemoteComputer.HostName)..."
                if ($Session.ComputerName -eq $RemoteComputer.FQDN) {
                    $RemoteSession = $Session
                } else {
                    $RemoteSession = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN 
                }        
                if ($ApplicationLicense) {
                    Set-NAVRemoteInstanceTenantLicense -Session $RemoteSession -SelectedTenant $SelectedTenant -LicenseData $LicenseData -ApplicationLicense
                } else {
                    Set-NAVRemoteInstanceTenantLicense -Session $RemoteSession -SelectedTenant $SelectedTenant -LicenseData $LicenseData
                }

                if ($Session.ComputerName -ne $RemoteSession.ComputerName) { Remove-PSSession -Session $RemoteSession }
            }
        }
    }    
}