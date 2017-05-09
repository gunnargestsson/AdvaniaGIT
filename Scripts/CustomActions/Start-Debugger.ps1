Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
[xml]$clientUserSettings = Get-Content -Path (Join-Path $env:ProgramData ('Microsoft\Microsoft Dynamics NAV\' + $SetupParameters.mainVersion + '\ClientUserSettings.config'))
$clientSettingsPath = (Join-Path $LogPath 'ClientUserSettings.config')
$clientexe = (Join-Path $SetupParameters.navIdePath 'Microsoft.Dynamics.Nav.Client.exe')
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'Server' -NewValue $env:COMPUTERNAME
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ClientServicesPort' -NewValue $BranchSettings.clientServicesPort
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServerInstance' -NewValue $BranchSettings.instanceName
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'UrlHistory' -NewValue ""
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'UnknownSpnHint' -NewValue ""
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'TenantId' -NewValue ""
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ClientServicesCredentialType' -NewValue Windows
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicesCertificateValidationEnabled' -NewValue false
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicePrincipalNameRequired' -NewValue false
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServer' -NewValue (Get-HelpServer -mainVersion $SetupParameters.mainVersion)
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServerPort' -NewValue (Get-HelpServerPort -mainVersion $SetupParameters.mainVersion)
Set-Content -Path $clientSettingsPath -Value $clientUserSettings.OuterXml -Force
$params = @()
$params += @('-settings:"' + $clientSettingsPath + '"')
$params += " `"DynamicsNAV://///debug`""
Write-Host "Running: `"$clientexe`" $params" -ForegroundColor Green
Start-Process -FilePath $clientexe -ArgumentList $params
