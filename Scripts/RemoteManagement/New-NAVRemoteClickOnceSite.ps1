Function New-NAVRemoteClickOnceSite {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    {
        $TenantSettings = Get-NAVRemoteInstanceTenantSettings -Session $Session -SelectedTenant $SelectedTenant
        $SelectedTenant = Combine-Settings $TenantSettings $SelectedTenant

        if ($SelectedTenant.CustomerName -eq "") {
            Write-Host -ForegroundColor Red "Customer Name not configured.  Configure with Tenant Settings."
            break
        } elseif ($SelectedTenant.ClickOnceHost -eq "") {
            Write-Host -ForegroundColor Red "ClickOnce Host not configured.  Configure with Tenant Settings."
            break
        } elseif (!(Resolve-DnsName -Name $SelectedTenant.ClickOnceHost -ErrorAction SilentlyContinue)) {
            Write-Host -ForegroundColor Red "Host $($SelectedTenant.ClickOnceHost) not found in Dns!"
            break
        }
        Write-Host "Building ClickOnce Site for $($SelectedTenant.CustomerName)..."

        $RemoteConfig = Get-RemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*ClickOnce*") {
                Write-Host "Updating $($RemoteComputer.HostName)..."
                if ($Session.ComputerName -eq $RemoteComputer.FQDN) {
                    $RemoteSession = $Session
                } else {
                    $RemoteSession = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN 
                }
                # Prepare and Clean Up        
                Invoke-Command -Session $RemoteSession -ScriptBlock `
                    {
                        Param([PSObject]$SelectedTenant)
                        if (!(Test-Path (Join-Path $env:SystemDrive "inetpub\wwwroot\ClickOnce"))) {
                            New-Item -Path (Join-Path $env:SystemDrive "inetpub\wwwroot\ClickOnce") -ItemType Directory | Out-Null
                        }
                        $ExistingWebSite = Get-Website -Name "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)"
                        if ($ExistingWebSite) {
                            Write-Host "Removing old ClickOnce Site..."
                            Get-ChildItem "IIS:\SslBindings" | Where-Object -Property Sites -eq "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" | Remove-Item -Force
                            $ExistingWebSite | Remove-Website 
                            Remove-Item -Path $ExistingWebSite.PhysicalPath -Recurse -Force                            
                        }                           
                    } -ArgumentList $SelectedTenant -ErrorAction Stop
                # Do some tests and import modules 
                Invoke-Command -Session $RemoteSession -ScriptBlock `
                    {
                        Param([PSObject]$HostConfig)
                        if (!(Test-Path $SetupParameters.MageExeLocation)) {
                            Throw "Mage.exe not found on $($HostConfig.FQDN)!"
                        }

                        if (!(Test-Path $SetupParameters.codeSigningCertificate)) {
                            Throw "Code Signing Certificate not found on $($HostConfig.FQDN)!"
                        }

                        if ($SetupParameters.codeSigningCertificatePassword -eq "") {
                            Throw "Password for Code Signing Certificate not found on $($HostConfig.FQDN)!"
                        }

                        Write-Host "Importing NAV DVD Management Module..."
                        $NAVDVDFilePath = $HostConfig.NAVDVDPath
                        $NAVModulePath = Join-Path $NAVDVDFilePath "WindowsPowerShellScripts\Cloud\NAVAdministration\NAVAdministration.psm1"
                        if (Test-Path $NAVModulePath) {
                            Import-Module $NAVModulePath -DisableNameChecking -ErrorAction Stop
                        } else {
                            Throw "NAV DVD Module not found on $($HostConfig.FQDN)!"
                        }

                        Write-Host "Importing IIS Management PowerShell Module..."
                        Import-Module WebAdministration

                    } -ArgumentList $RemoteComputer

                # Create the ClickOnce Site
                Invoke-Command -Session $RemoteSession -ScriptBlock `
                    {
                        Param([PSObject]$SelectedInstance, [PSObject]$SelectedTenant, [PSObject]$Remotes)
                        Write-Host "Creating Client Configuration..."
                        $clickOnceCodeSigningPfxPasswordAsSecureString = ConvertTo-SecureString -String $SetupParameters.codeSigningCertificatePassword -AsPlainText -Force
                        $clickOnceDeploymentId = "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)"
                        $clickOnceDirectory = Join-Path (Join-Path $env:SystemDrive "inetpub\wwwroot\ClickOnce") $clickOnceDeploymentId
                        Remove-Item -Path $clickOnceDirectory -Recurse -Force -ErrorAction SilentlyContinue
                        $webSiteUrl = ("https://" + $SelectedTenant.ClickOnceHost)
                        [xml]$clientUserSettings = Get-Content -Path (Join-Path $env:ProgramData ('Microsoft\Microsoft Dynamics NAV\' + $SetupParameters.mainVersion + '\ClientUserSettings.config'))                       

                        for ($i=1
                         $i -lt ((Split-Path (Split-Path $SelectedInstance.PublicWinBaseUrl -Parent) -Leaf).Split(':').GetValue(0)).Split('.').Count
                         $i++){
                            if ($DnsIdentity) {
                                $DnsIdentity += "." + ((Split-Path (Split-Path $SelectedInstance.PublicWinBaseUrl -Parent) -Leaf).Split(':').GetValue(0)).Split('.').GetValue($i)
                            } else {
                                $DnsIdentity = ((Split-Path (Split-Path $SelectedInstance.PublicWinBaseUrl -Parent) -Leaf).Split(':').GetValue(0)).Split('.').GetValue($i)
                            }
                         }
                        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'Server' -NewValue (Split-Path (Split-Path $SelectedInstance.PublicWinBaseUrl -Parent) -Leaf).Split(':').GetValue(0)
                        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ClientServicesPort' -NewValue (Split-Path (Split-Path $SelectedInstance.PublicWinBaseUrl -Parent) -Leaf).Split(':').GetValue(1)
                        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServerInstance' -NewValue (Split-Path $SelectedInstance.PublicWinBaseUrl -Leaf)
                        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'UrlHistory' -NewValue ""
                        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'DnsIdentity' -NewValue $DnsIdentity
                        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'TenantId' -NewValue $SelectedTenand.Id
                        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ClientServicesCredentialType' -NewValue $SelectedInstance.ClientServicesCredentialType
                        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicesCertificateValidationEnabled' -NewValue false
                        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicePrincipalNameRequired' -NewValue false
                        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicePrincipalNameRequired' -NewValue false
                        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServer' -NewValue (Get-HelpServer -mainVersion $SetupParameters.mainVersion)
                        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServerPort' -NewValue (Get-HelpServerPort -mainVersion $SetupParameters.mainVersion)

                        Write-Host "Creating ClickOnce Directory..."
                        New-ClickOnceDirectory -ClientUserSettings $clientUserSettings -ClickOnceDirectory $clickOnceDirectory

                        Write-Host "Adjusting the application manifest (Microsoft.Dynamics.Nav.Client.exe.manifest)..."
                        $applicationFilesDirectory = Join-Path $clickOnceDirectory 'Deployment\ApplicationFiles'
                        $applicationManifestFile = Join-Path $applicationFilesDirectory 'Microsoft.Dynamics.Nav.Client.exe.manifest'
                        $applicationIdentityName = "$clickOnceDeploymentId application identity"
                        $NAVClientFile = (Join-Path $applicationFilesDirectory 'Microsoft.Dynamics.Nav.Client.exe')
                        $applicationIdentityVersion = (Get-ItemProperty -Path $NAVClientFile).VersionInfo.FileVersion

                        Set-ApplicationManifestFileList `
                            -ApplicationManifestFile $applicationManifestFile `
                            -ApplicationFilesDirectory $applicationFilesDirectory `
                            -MageExeLocation $SetupParameters.MageExeLocation

                        Set-ApplicationManifestApplicationIdentity `
                            -ApplicationManifestFile $applicationManifestFile `
                            -ApplicationIdentityName $applicationIdentityName `
                            -ApplicationIdentityVersion $applicationIdentityVersion

                        Write-Host "Signing the application manifest..."
                        Start-ProcessWithErrorHandling -FilePath $SetupParameters.MageExeLocation -ArgumentList "-Sign `"$applicationManifestFile`" -CertFile `"$($SetupParameters.codeSigningCertificate)`" -password $($SetupParameters.codeSigningCertificatePassword)" 

                        Write-Host "Adjusting the deployment manifest (Microsoft.Dynamics.Nav.Client.application)..."
                        $deploymentManifestFile = Join-Path $clickOnceDirectory 'Deployment\Microsoft.Dynamics.Nav.Client.application'
                        $deploymentIdentityName = "$clickOnceDeploymentId deployment identity" 
                        $deploymentIdentityVersion = $applicationIdentityVersion
                        $deploymentManifestUrl = ($webSiteUrl + "/Deployment/Microsoft.Dynamics.Nav.Client.application")
                        $applicationManifestUrl = ($webSiteUrl + "/Deployment/ApplicationFiles/Microsoft.Dynamics.Nav.Client.exe.manifest")
                        $applicationName = "$($Remotes.ClickOnceAApplicationName) fyrir $($SelectedTenant.CustomerName)"

                        Set-DeploymentManifestApplicationReference `
                            -DeploymentManifestFile $deploymentManifestFile `
                            -ApplicationManifestFile $applicationManifestFile `
                            -ApplicationManifestUrl $applicationManifestUrl `
                            -MageExeLocation $SetupParameters.MageExeLocation

                        Set-DeploymentManifestSettings `
                            -DeploymentManifestFile $deploymentManifestFile `
                            -DeploymentIdentityName $deploymentIdentityName `
                            -DeploymentIdentityVersion $deploymentIdentityVersion `
                            -DeploymentManifestUrl $deploymentManifestUrl `
                            -ApplicationPublisher $Remotes.ClickOnceApplicationPublisher `
                            -ApplicationName $applicationName

                        Write-Host "Signing the deployment manifest..."
                        Start-ProcessWithErrorHandling -FilePath $SetupParameters.MageExeLocation -ArgumentList "-Sign `"$deploymentManifestFile`" -CertFile `"$($SetupParameters.codeSigningCertificate)`" -password $($SetupParameters.codeSigningCertificatePassword)" 

                        Write-Host "Putting a web.config file in the root folder, which will tell IIS which .html file to open..."
                        $AdminRemoteDirectory = Join-Path $NAVDVDFilePath 'WindowsPowerShellScripts\Cloud\NAVAdministration'
                        $sourceFile = Join-Path $AdminRemoteDirectory 'ClickOnce\Resources\root_web.config'
                        $targetFile = Join-Path $clickOnceDirectory 'web.config'
                        Copy-Item $sourceFile -destination $targetFile

                        Write-Host "Putting a web.config file in the Deployment folder, which will tell IIS to allow downloading of .config files etc..."
                        $sourceFile = Join-Path $AdminRemoteDirectory 'ClickOnce\Resources\deployment_web.config'
                        $targetFile = Join-Path $clickOnceDirectory 'Deployment\web.config'
                        Copy-Item $sourceFile -destination $targetFile

                        Write-Host "Creating the web site..."
                        New-Website -Name "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -PhysicalPath $clickOnceDirectory -HostHeader $SelectedTenant.ClickOnceHost -Force
                        Write-Host "Adding web site binding..."
                        $certificate = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Thumbprint -eq $SelectedInstance.ServicesCertificateThumbprint} 
                        New-Item -Path "IIS:\SslBindings\!443!$($SelectedTenant.ClickOnceHost)" -Value $certificate -SSLFlags 1 
                        New-WebBinding -Name "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -Protocol "https" -Port 443 -HostHeader $SelectedTenant.ClickOnceHost -SslFlags 1

                    } -ArgumentList ($SelectedInstance, $SelectedTenant, $Remotes) -ErrorAction Stop

                if ($Session.ComputerName -ne $RemoteSession.ComputerName) { Remove-PSSession -Session $RemoteSession }
            }
        }
    }
}