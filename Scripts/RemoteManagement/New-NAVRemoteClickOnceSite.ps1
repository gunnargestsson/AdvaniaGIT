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
        [String]$ClickOnceApplicationPublisher,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$TestDeploymentServer
    )
    PROCESS 
    {
        # Create the ClickOnce Site        
        $ClickOncesite = Invoke-Command -Session $Session -ScriptBlock `
            {
                Param([PSObject]$SelectedInstance, [PSObject]$SelectedTenant, [PSObject]$ClientSettings, [String]$ClickOnceApplicationName, [String]$ClickOnceApplicationPublisher, [String]$DnsIdentity, [string]$TestDeploymentServer)
                               
                Write-Host "Creating Client Configuration..."
                $clickOnceCodeSigningPfxPasswordAsSecureString = ConvertTo-SecureString -String $SetupParameters.codeSigningCertificatePassword -AsPlainText -Force
                $clickOnceDeploymentId = "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)"

                $wwwRootPath = (Get-Item "HKLM:\SOFTWARE\Microsoft\InetStp").GetValue("PathWWWRoot")
                $wwwRootPath = [System.Environment]::ExpandEnvironmentVariables($wwwRootPath)
                $clickOnceDirectory = Join-Path (Join-Path $wwwRootPath "ClickOnce") $clickOnceDeploymentId
                Remove-Item -Path $clickOnceDirectory -Recurse -Force -ErrorAction SilentlyContinue
                $webSiteUrl = "https://$($SelectedTenant.ClickOnceHost)"
                [xml]$clientUserSettings = Get-Content -Path (Join-Path $env:ProgramData ('Microsoft\Microsoft Dynamics NAV\' + $SetupParameters.mainVersion + '\ClientUserSettings.config'))                       

                Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'Server' -NewValue (Split-Path (Split-Path $SelectedInstance.PublicWinBaseUrl -Parent) -Leaf).Split(':').GetValue(0)
                Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ClientServicesPort' -NewValue (Split-Path (Split-Path $SelectedInstance.PublicWinBaseUrl -Parent) -Leaf).Split(':').GetValue(1)
                Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServerInstance' -NewValue (Split-Path $SelectedInstance.PublicWinBaseUrl -Leaf)
                Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'UrlHistory' -NewValue ""
                Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'DnsIdentity' -NewValue $DnsIdentity
                Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'TenantId' -NewValue $SelectedTenant.Id
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
                $applicationIdentityName = "$ClickOnceApplicationPublisher_$clickOnceDeploymentId"
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
                $deploymentIdentityName = "$ClickOnceApplicationPublisher_$clickOnceDeploymentId"
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
                if ([int]($SelectedInstance.Version).split('.')[0] -lt 13) {
                    Write-Host "Adding web site binding..."
                    $certificateSubject = "CN=*.$($SelectedTenant.ClickOnceHost.Split(".")[1]).$($SelectedTenant.ClickOnceHost.Split(".")[2])*"
                    $certificate = Get-ChildItem Cert:\LocalMachine\My | Where-Object -Property Subject -like $certificateSubject
                    Write-Host "Found Certificate $($certificate.Thumbprint) for $($SelectedTenant.ClickOnceHost)..."
                    New-Item -Path "IIS:\SslBindings\!443!$($SelectedTenant.ClickOnceHost)" -Value $certificate -SSLFlags 1 -ErrorAction SilentlyContinue
                    New-WebBinding -Name "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -Protocol "https" -Port 443 -HostHeader $SelectedTenant.ClickOnceHost -SslFlags 1
                }

                Write-Host "Creating the web, soap and odata redirect..."
                New-Item -Path (Join-Path $clickOnceDirectory "web") -ItemType Directory -ErrorAction SilentlyContinue
                New-Item -Path (Join-Path $clickOnceDirectory "soap") -ItemType Directory -ErrorAction SilentlyContinue
                New-Item -Path (Join-Path $clickOnceDirectory "odata") -ItemType Directory -ErrorAction SilentlyContinue
                New-WebVirtualDirectory -Site "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -Name "Web" -PhysicalPath (Join-Path $clickOnceDirectory "web")                
                New-WebVirtualDirectory -Site "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -Name "Soap" -PhysicalPath (Join-Path $clickOnceDirectory "soap")
                New-WebVirtualDirectory -Site "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -Name "OData" -PhysicalPath (Join-Path $clickOnceDirectory "odata")
                Set-WebConfiguration system.webServer/httpRedirect "IIS:\sites\$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)\Web" -Value @{enabled="true";destination="$($SelectedInstance.PublicWebBaseUrl)?tenant=$($SelectedTenant.Id)";exactDestination="true";httpResponseStatus="Permanent"}
                Set-WebConfiguration system.webServer/httpRedirect "IIS:\sites\$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)\Soap" -Value @{enabled="true";destination="$($SelectedInstance.PublicSOAPBaseUrl)/Services?tenant=$($SelectedTenant.Id)";exactDestination="true";httpResponseStatus="Permanent"}
                Set-WebConfiguration system.webServer/httpRedirect "IIS:\sites\$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)\OData" -Value @{enabled="true";destination="$($SelectedInstance.PublicODataBaseUrl)?tenant=$($SelectedTenant.Id)";exactDestination="true";httpResponseStatus="Permanent"}

                $addLinksLines = "        <p>`r`n"
                $addLinksLines += "            <a target=`"_blank`" href=`"Web`">Web Client with password authentication</a><label> | </label>`r`n"
                if ($SelectedInstance.AppIdUri -gt "") {
                    $addLinksLines += "            <a target=`"_blank`" href=`"Web365`">Web Client with Office 365 authentication</a><label> | </label>`r`n"
                }
                if (![System.String]::IsNullOrEmpty($TestDeploymentServer)) {
                    $addLinksLines += "            <a target=`"_blank`" href=`"WebTest`">Web Client for testing</a><label> | </label>`r`n"
                }

                $addLinksLines += "            <a target=`"_blank`" href=`"Soap`">Soap web service</a><label> | </label>`r`n"
                $addLinksLines += "            <a target=`"_blank`" href=`"OData`">OData web service</a>`r`n"

                 if ([bool]($SelectedInstance.PSObject.Properties.name -match "ODataServicesV4EndpointEnabled")) {
                      New-Item -Path (Join-Path $clickOnceDirectory "odataV4") -ItemType Directory -ErrorAction SilentlyContinue
                      New-WebVirtualDirectory -Site "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -Name "ODataV4" -PhysicalPath (Join-Path $clickOnceDirectory "odataV4")
                      Set-WebConfiguration system.webServer/httpRedirect "IIS:\sites\$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)\ODataV4" -Value @{enabled="true";destination="$($SelectedInstance.PublicODataBaseUrl)V4?tenant=$($SelectedTenant.Id)";exactDestination="true";httpResponseStatus="Permanent"}
                      $addLinksLines += "            <label> | </label><a target=`"_blank`" href=`"ODataV4`">OData web service version 4</a>`r`n"
                    }

                $addLinksLines += "        </p>`r`n"
                AddTo-NAVClientInstallation -NAVClientInstallationPath (Join-Path $clickOnceDirectory 'NAVClientInstallation.html') -BeforeLineContaining "<p>" -InsertContent $addLinksLines
                $updClientInstallLine = "                    <p><input class=`"viptile`" id=`"installNavButton`" type=`"button`" value=`"Password authentication`" onclick=`"onInstallNavClicked()`" /></p>"
                Replace-NAVClientInstallation -NAVClientInstallationPath (Join-Path $clickOnceDirectory 'NAVClientInstallation.html') -LineContaining "installNavButton" -NewInsertContent $updClientInstallLine


                if ($SelectedInstance.AppIdUri -gt "") {
                    Write-Host "Creating Client 365 Configuration..."
                    $clickOnceCodeSigningPfxPasswordAsSecureString = ConvertTo-SecureString -String $SetupParameters.codeSigningCertificatePassword -AsPlainText -Force
                    $clickOnceDeploymentId = "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)"
                    $clickOnceDirectory = Join-Path (Join-Path $wwwRootPath "ClickOnce") $clickOnceDeploymentId
                    $clickOnceDirectory = Join-Path $clickOnceDirectory "365"
                    $clickOnceDeploymentId += "365"
                    $AzureADDomain = $SelectedInstance.ClientServicesFederationMetadataLocation.split("/").GetValue(3)
                    Remove-Item -Path $clickOnceDirectory -Recurse -Force -ErrorAction SilentlyContinue
                    $webSiteUrl = "https://$($SelectedTenant.ClickOnceHost)/365"
                    [xml]$clientUserSettings = Get-Content -Path (Join-Path $env:ProgramData ('Microsoft\Microsoft Dynamics NAV\' + $SetupParameters.mainVersion + '\ClientUserSettings.config'))                       

                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'Server' -NewValue (Split-Path (Split-Path $SelectedInstance.PublicWinBaseUrl -Parent) -Leaf).Split(':').GetValue(0)
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ClientServicesPort' -NewValue (Split-Path (Split-Path $SelectedInstance.PublicWinBaseUrl -Parent) -Leaf).Split(':').GetValue(1)
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServerInstance' -NewValue (Split-Path $SelectedInstance.PublicWinBaseUrl -Leaf)
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'UrlHistory' -NewValue ""
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'DnsIdentity' -NewValue $DnsIdentity
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'TenantId' -NewValue $SelectedTenant.Id
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ClientServicesCredentialType' -NewValue AccessControlService
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicesCertificateValidationEnabled' -NewValue false
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicePrincipalNameRequired' -NewValue false
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicePrincipalNameRequired' -NewValue false
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServer' -NewValue $ClientSettings.HelpServer
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServerPort' -NewValue $ClientSettings.HelpServerPort
                    if ([int]($SelectedInstance.Version).split('.')[0] -ge 13) {
                        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ACSUri' -NewValue "https://login.microsoftonline.com/common/wsfed?wa=wsignin1.0%26wtrealm=$($SelectedInstance.AppIdUri)%26wreply=$($SelectedInstance.PublicWebBaseUrl)365/SignIn"
                    } else {
                        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ACSUri' -NewValue "https://login.windows.net/common/wsfed?wa=wsignin1.0%26wtrealm=$($SelectedInstance.AppIdUri)%26wreply=$($SelectedInstance.PublicWebBaseUrl)365/WebClient/SignIn.aspx"
                    }

                    Write-Host "Creating ClickOnce 365 Directory..."
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
                    $applicationName = "$ClickOnceApplicationName fyrir 365 $($SelectedTenant.CustomerName)"

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

                    Write-Host "Putting a web.config file in the Deployment folder, which will tell IIS to allow downloading of .config files etc..."
                    $sourceFile = Join-Path $AdminRemoteDirectory 'ClickOnce\Resources\deployment_web.config'
                    $targetFile = Join-Path $clickOnceDirectory 'Deployment\web.config'
                    Copy-Item $sourceFile -destination $targetFile

                    Write-Host "Creating the ClickOnce and Web 365 Sites"
                    New-WebVirtualDirectory -Site "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -Name "365" -PhysicalPath $clickOnceDirectory
                    New-Item -Path (Join-Path (Split-Path $clickOnceDirectory -Parent) "web365") -ItemType Directory -ErrorAction SilentlyContinue
                    New-WebVirtualDirectory -Site "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -Name "Web365" -PhysicalPath (Join-Path (Split-Path $clickOnceDirectory -Parent) "web365")
                    Set-WebConfiguration system.webServer/httpRedirect "IIS:\sites\$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)\Web365" -Value @{enabled="true";destination="$($SelectedInstance.PublicWebBaseUrl)365?tenant=$($SelectedTenant.Id)";exactDestination="true";httpResponseStatus="Permanent"}

                    $inst365 = "        function onInstallNav365Clicked() {
            if (document.SampleForm.acceptMicrosoftLicenseCheckbox.checked == false) {
                alert('You must accept the license terms to continue.');
            }
            else {
                open('365/Deployment/Microsoft.Dynamics.Nav.Client.application');
            }
        }"
                    $inst365button = "                    <p><input class=`"viptile`" id=`"installNav365Button`" type=`"button`" value=`"Office 365 authentication`" onclick=`"onInstallNav365Clicked()`" /></p>"

                    AddTo-NAVClientInstallation -NAVClientInstallationPath (Join-Path (Split-Path $clickOnceDirectory -Parent) 'NAVClientInstallation.html') -BeforeLineContaining "function onInstallNavClicked()" -InsertContent $inst365
                    AddTo-NAVClientInstallation -NAVClientInstallationPath (Join-Path (Split-Path $clickOnceDirectory -Parent) 'NAVClientInstallation.html') -AfterLineContaining "installNavButton" -InsertContent $inst365button
                }

                if (![System.String]::IsNullOrEmpty($TestDeploymentServer)) {
                    Write-Host "Creating Test Client Configuration..."
                    $clickOnceCodeSigningPfxPasswordAsSecureString = ConvertTo-SecureString -String $SetupParameters.codeSigningCertificatePassword -AsPlainText -Force
                    $clickOnceDeploymentId = "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)"
                    $clickOnceDirectory = Join-Path (Join-Path $wwwRootPath "ClickOnce") $clickOnceDeploymentId
                    $clickOnceDirectory = Join-Path $clickOnceDirectory "Test"
                    $clickOnceDeploymentId += "Test"
                    $AzureADDomain = $SelectedInstance.ClientServicesFederationMetadataLocation.split("/").GetValue(3)
                    Remove-Item -Path $clickOnceDirectory -Recurse -Force -ErrorAction SilentlyContinue
                    $webSiteUrl = "https://$($SelectedTenant.ClickOnceHost)/Test"
                    [xml]$clientUserSettings = Get-Content -Path (Join-Path $env:ProgramData ('Microsoft\Microsoft Dynamics NAV\' + $SetupParameters.mainVersion + '\ClientUserSettings.config'))                       

                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'Server' -NewValue $TestDeploymentServer
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ClientServicesPort' -NewValue (Split-Path (Split-Path $SelectedInstance.PublicWinBaseUrl -Parent) -Leaf).Split(':').GetValue(1)
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServerInstance' -NewValue (Split-Path $SelectedInstance.PublicWinBaseUrl -Leaf)
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'UrlHistory' -NewValue ""
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'DnsIdentity' -NewValue $DnsIdentity
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'TenantId' -NewValue default
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ClientServicesCredentialType' -NewValue $SelectedInstance.ClientServicesCredentialType
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicesCertificateValidationEnabled' -NewValue false
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicePrincipalNameRequired' -NewValue false
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicePrincipalNameRequired' -NewValue false
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServer' -NewValue $ClientSettings.HelpServer
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServerPort' -NewValue $ClientSettings.HelpServerPort
                    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ACSUri' -NewValue ""

                    Write-Host "Creating ClickOnce Test Directory..."
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
                    $applicationName = "$ClickOnceApplicationName fyrir prófun $($SelectedTenant.CustomerName)"

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

                    Write-Host "Putting a web.config file in the Deployment folder, which will tell IIS to allow downloading of .config files etc..."
                    $sourceFile = Join-Path $AdminRemoteDirectory 'ClickOnce\Resources\deployment_web.config'
                    $targetFile = Join-Path $clickOnceDirectory 'Deployment\web.config'
                    Copy-Item $sourceFile -destination $targetFile

                    Write-Host "Creating the ClickOnce and Web Test Sites"
                    New-WebVirtualDirectory -Site "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -Name "Test" -PhysicalPath $clickOnceDirectory
                    New-Item -Path (Join-Path (Split-Path $clickOnceDirectory -Parent) "webTest") -ItemType Directory -ErrorAction SilentlyContinue
                    New-WebVirtualDirectory -Site "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" -Name "WebTest" -PhysicalPath (Join-Path (Split-Path $clickOnceDirectory -Parent) "webTest")
                    Set-WebConfiguration system.webServer/httpRedirect "IIS:\sites\$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)\WebTest" -Value @{enabled="true";destination="$($SelectedInstance.PublicWebBaseUrl)Test?tenant=default";exactDestination="true";httpResponseStatus="Permanent"}
                    $instTest = "        function onInstallNavTestClicked() {
            if (document.SampleForm.acceptMicrosoftLicenseCheckbox.checked == false) {
                alert('You must accept the license terms to continue.');
            }
            else {
                open('Test/Deployment/Microsoft.Dynamics.Nav.Client.application');
            }
        }"
                    $instTestbutton = "                    <p><input class=`"viptile`" id=`"installNavTestButton`" type=`"button`" value=`"Testing`" onclick=`"onInstallNavTestClicked()`" /></p>"

                    AddTo-NAVClientInstallation -NAVClientInstallationPath (Join-Path (Split-Path $clickOnceDirectory -Parent) 'NAVClientInstallation.html') -BeforeLineContaining "function onInstallNavClicked()" -InsertContent $instTest
                    AddTo-NAVClientInstallation -NAVClientInstallationPath (Join-Path (Split-Path $clickOnceDirectory -Parent) 'NAVClientInstallation.html') -AfterLineContaining "installNavButton" -InsertContent $instTestbutton

                }


            } -ArgumentList ($SelectedInstance, $SelectedTenant, $ClientSettings, $ClickOnceApplicationName, $ClickOnceApplicationPublisher, (Get-NAVDnsIdentity -SelectedInstance $SelectedInstance), $TestDeploymentServer)
    }
}