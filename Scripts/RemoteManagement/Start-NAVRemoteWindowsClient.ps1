Function Start-NAVRemoteWindowsClient {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$TenantId="default"
    )

    $RemoteSetupParameters = New-Object -TypeName PSObject
    $RemoteSetupParameters | Add-Member -MemberType NoteProperty -Name navVersion -Value $SelectedInstance.Version
    $RemoteSetupParameters | Add-Member -MemberType NoteProperty -Name mainVersion -Value (($SelectedInstance.Version).Split('.').GetValue(0) + ($SelectedInstance.Version).Split('.').GetValue(1))
    $navIdePath = Get-NAVClientPath -SetupParameters $RemoteSetupParameters

    [xml]$clientUserSettings = Get-Content -Path (Join-Path $env:ProgramData ('Microsoft\Microsoft Dynamics NAV\' + $RemoteSetupParameters.mainVersion + '\ClientUserSettings.config'))
    $clientSettingsPath = (Join-Path $env:APPDATA "Microsoft\Microsoft Dynamics NAV\$($RemoteSetupParameters.mainVersion)\$($SelectedInstance.ServerInstance).config")
    $clientexe = (Join-Path $navIdePath 'Microsoft.Dynamics.Nav.Client.exe')
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
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'TenantId' -NewValue $TenantId
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ClientServicesCredentialType' -NewValue $SelectedInstance.ClientServicesCredentialType
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicesCertificateValidationEnabled' -NewValue false
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicePrincipalNameRequired' -NewValue false
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicePrincipalNameRequired' -NewValue false
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServer' -NewValue (Get-HelpServer -mainVersion $RemoteSetupParameters.mainVersion)
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServerPort' -NewValue (Get-HelpServerPort -mainVersion $RemoteSetupParameters.mainVersion)
    New-Item -Path (Split-Path $clientSettingsPath -Parent) -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    Set-Content -Path $clientSettingsPath -Value $clientUserSettings.OuterXml -Force
    $params = @()
    $params += @('-settings:"' + $clientSettingsPath + '"')    
    Start-Process -FilePath $clientexe -ArgumentList $params
}