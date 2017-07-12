Function New-NAVRemoteClickOnceSite {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$ClientSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$ClickOnceApplicationName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$ClickOnceApplicationPublisher
    )
    PROCESS 
    {
        # Create the ClickOnce Site
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                Param([PSObject]$SelectedInstance, [PSObject]$SelectedTenant, [PSObject]$ClientSettings, [String]$ClickOnceApplicationName, [String]$ClickOnceApplicationPublisher, [String]$DnsIdentity)
                Write-Host "Creating Client Configuration..."
                $clickOnceCodeSigningPfxPasswordAsSecureString = ConvertTo-SecureString -String $SetupParameters.codeSigningCertificatePassword -AsPlainText -Force
                $clickOnceDeploymentId = "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)"
                $clickOnceDirectory = Join-Path (Join-Path $env:SystemDrive "inetpub\wwwroot\ClickOnce") $clickOnceDeploymentId
                Remove-Item -Path $clickOnceDirectory -Recurse -Force -ErrorAction SilentlyContinue
                $webSiteUrl = ("https://" + $SelectedTenant.ClickOnceHost)
                [xml]$clientUserSettings = Get-Content -Path (Join-Path $env:ProgramData ('Microsoft\Microsoft Dynamics NAV\' + $SetupParameters.mainVersion + '\ClientUserSettings.config'))                       

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
                Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServer' -NewValue $ClientSettings.HelpServer
                Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServerPort' -NewValue $ClientSettings.HelpServerPort

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
                $applicationName = "$ClickOnceApplicationName fyrir $($SelectedTenant.CustomerName)"

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
                    -ApplicationPublisher $ClickOnceApplicationPublisher `
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
                New-Item -Path "IIS:\SslBindings\!443!$($SelectedTenant.ClickOnceHost)" -Value $certificate -SSLFlags 1 -ErrorAction SilentlyContinue
                New-WebBinding -Name "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -Protocol "https" -Port 443 -HostHeader $SelectedTenant.ClickOnceHost -SslFlags 1

                Write-Host "Creating the web, soap and odata redirect..."
                New-Item -Path (Join-Path $clickOnceDirectory "web") -ItemType Directory -ErrorAction SilentlyContinue
                New-Item -Path (Join-Path $clickOnceDirectory "soap") -ItemType Directory -ErrorAction SilentlyContinue
                New-Item -Path (Join-Path $clickOnceDirectory "odata") -ItemType Directory -ErrorAction SilentlyContinue
                New-WebVirtualDirectory -Site "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -Name "Web" -PhysicalPath (Join-Path $clickOnceDirectory "web")
                New-WebVirtualDirectory -Site "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -Name "Soap" -PhysicalPath (Join-Path $clickOnceDirectory "soap")
                New-WebVirtualDirectory -Site "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -Name "OData" -PhysicalPath (Join-Path $clickOnceDirectory "odata")
                Set-WebConfiguration system.webServer/httpRedirect "IIS:\sites\$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)\Web" -Value @{enabled="true";destination="$($SelectedInstance.PublicWebBaseUrl)";exactDestination="true";httpResponseStatus="Permanent"}
                Set-WebConfiguration system.webServer/httpRedirect "IIS:\sites\$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)\Soap" -Value @{enabled="true";destination="$($SelectedInstance.PublicSOAPBaseUrl)";exactDestination="true";httpResponseStatus="Permanent"}
                Set-WebConfiguration system.webServer/httpRedirect "IIS:\sites\$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)\OData" -Value @{enabled="true";destination="$($SelectedInstance.PublicODataBaseUrl)";exactDestination="true";httpResponseStatus="Permanent"}

            } -ArgumentList ($SelectedInstance, $SelectedTenant, $ClientSettings, $ClickOnceApplicationName, $ClickOnceApplicationPublisher, (Get-NAVDnsIdentity -SelectedInstance $SelectedInstance)) -ErrorAction Stop        
    }
}