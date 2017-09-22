Function New-NAVDeploymentRemoteLicenses {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    {    
        Write-Host "Loading Instances for $DeploymentName..."

        $RemoteConfig = Get-NAVRemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName

        $Instances = Load-NAVRemoteInstanceMenu -Credential $Credential -RemoteConfig $RemoteConfig -DeploymentName $DeploymentName
        $Instances = Get-NAVSelectedInstances -ServerInstances $Instances
        if (!$Instances) { break }

        Foreach ($RemoteComputer in $Remotes.Hosts) {
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*ClickOnce*") {
                Write-Host "Updating $($RemoteComputer.HostName)..."
                $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN 

                Foreach ($SelectedInstance in $Instances) {
                    Foreach ($SelectedTenant in $SelectedInstance.TenantList) {
                        
                        if ($SelectedTenant.LicenseNo -gt "" ) {
                            $FtpFileName = "license/$($SelectedTenant.LicenseNo).flf"
                            $LocalFileName = Join-Path $env:TEMP "$($SelectedTenant.LicenseNo).flf"
                            try { Get-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpFilePath $FtpFileName -LocalFilePath $LocalFileName }
                            catch { Write-Host "Unable to download license from $LocalFileName !" }
                            finally {
                                if (Test-Path $LocalFileName) {
                                    $LicenseData = [Byte[]] (Get-Content -Path $LocalFileName -Encoding Byte)
                                    Remove-Item -Path $LocalFileName -Force -ErrorAction SilentlyContinue
    
                                    Set-NAVRemoteInstanceTenantLicense -Session $Session -SelectedTenant $SelectedTenant -LicenseData $LicenseData                         
                                }
                            }
                        }
                    }
                }
                Remove-PSSession -Session $Session 
            }
        }
    }
}