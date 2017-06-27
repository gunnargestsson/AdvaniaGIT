Function Set-NAVDeploymentRemoteInstanceTenantLicense {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    {
        if ($SelectedTenant.LicenseNo -eq "") {
            Throw "License Number is not defined in Tenant Settings!"
        }
        $FtpFileName = "license/$($SelectedTenant.LicenseNo).flf"
        $LocalFileName = Join-Path $env:TEMP "$($SelectedTenant.LicenseNo).flf"
        Get-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpFilePath $FtpFileName -LocalFilePath $LocalFileName
        if (!(Test-Path $LocalFileName)) {
            Write-Host -ForegroundColor Red "Unable to download the License File from $($SetupParameters.ftpServer)!"
            $anyKey = Read-Host "Press enter to continue..."
            break
        }
        $LicenseData = [Byte[]] (Get-Content -Path $LocalFileName -Encoding Byte)
        Remove-Item -Path $LocalFileName -Force -ErrorAction SilentlyContinue

        $RemoteConfig = Get-RemoteConfig
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

                Set-NAVRemoteInstanceTenantLicense -Session $RemoteSession -SelectedTenant $SelectedTenant -LicenseData $LicenseData

                if ($Session.ComputerName -ne $RemoteSession.ComputerName) { Remove-PSSession -Session $RemoteSession }
            }
        }
    }    
}