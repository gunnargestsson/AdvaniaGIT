$BaseSetupParameters = Get-BaseBranchSetupParameters -SetupParameters $SetupParameters
$BaseBranchSettings = Get-BranchSettings -SetupParameters $BaseSetupParameters    

Check-NAVServiceRunning -SetupParameters $BaseSetupParameters -BranchSettings $BaseBranchSettings
$clientSettingsPath = (Join-Path $SetupParameters.LogPath 'ClientUserSettings.config')

if ($BaseBranchSettings.dockerContainerId -gt "") {
    Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BaseBranchSettings
    $clientexe = (Join-Path $SetupParameters.LogPath 'RoleTailored Client\Microsoft.Dynamics.Nav.Client.exe')    
    [xml]$clientUserSettings = Get-Content -Path (Join-Path $SetupParameters.LogPath 'ClientUserSettings.config')
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'Server' -NewValue $BaseBranchSettings.dockerContainerName   
} else {    
    [xml]$clientUserSettings = Get-Content -Path (Join-Path $env:APPDATA ('Microsoft\Microsoft Dynamics NAV\' + $SetupParameters.mainVersion + '\ClientUserSettings.config'))
    $clientexe = (Join-Path $SetupParameters.navIdePath 'Microsoft.Dynamics.Nav.Client.exe')
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'Server' -NewValue $env:COMPUTERNAME
}

Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ClientServicesPort' -NewValue $BaseBranchSettings.clientServicesPort
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServerInstance' -NewValue $BaseBranchSettings.instanceName
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'UrlHistory' -NewValue ""
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'TenantId' -NewValue ""
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ClientServicesCredentialType' -NewValue Windows
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicesCertificateValidationEnabled' -NewValue false
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicePrincipalNameRequired' -NewValue false
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServer' -NewValue (Get-HelpServer -mainVersion $SetupParameters.mainVersion)
Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServerPort' -NewValue (Get-HelpServerPort -mainVersion $SetupParameters.mainVersion)
Set-Content -Path $clientSettingsPath -Value $clientUserSettings.OuterXml -Force
Set-Content -Path (Join-Path (Split-Path -Path $clientexe -Parent) 'ClientUserSettings.config') -Value $clientUserSettings.OuterXml -Force
$params = @()
$params += @('-settings:"' + $clientSettingsPath + '"')
Write-Host "Running: `"$clientexe`" $params" -ForegroundColor Green
Start-Process -FilePath $clientexe -ArgumentList $params
