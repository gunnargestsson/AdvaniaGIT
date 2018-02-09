function Prepare-NAVClient
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings
    )

    Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings

    if ($BranchSettings.dockerContainerId -gt "") {
        $clientPath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
        $clientexe = Join-Path $clientPath 'Microsoft.Dynamics.Nav.Client.exe'
        $clientSettingsPath = Join-Path $clientPath 'ClientUserSettings.config'
        [xml]$clientUserSettings = Get-Content -Path $clientSettingsPath
        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'Server' -NewValue $BranchSettings.dockerContainerName
    } else {    
        $clientexe = (Join-Path $SetupParameters.navIdePath 'Microsoft.Dynamics.Nav.Client.exe')
        $clientSettingsPath = (Join-Path $SetupParameters.LogPath 'ClientUserSettings.config')
        [xml]$clientUserSettings = Get-Content -Path (Join-Path $env:ProgramData ('Microsoft\Microsoft Dynamics NAV\' + $SetupParameters.mainVersion + '\ClientUserSettings.config'))
        if ([string]::IsNullOrEmpty($BranchSettings.instanceServer)) {
            $BranchSettings | Add-Member -MemberType NoteProperty -Name instanceServer -Value $env:COMPUTERNAME -Force
        }
        Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'Server' -NewValue $BranchSettings.instanceServer
    }

    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ClientServicesPort' -NewValue $BranchSettings.clientServicesPort
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServerInstance' -NewValue $BranchSettings.instanceName
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'UrlHistory' -NewValue ""
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'TenantId' -NewValue ""
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ClientServicesCredentialType' -NewValue Windows
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicesCertificateValidationEnabled' -NewValue false
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'ServicePrincipalNameRequired' -NewValue false
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServer' -NewValue (Get-HelpServer -mainVersion $SetupParameters.mainVersion)
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'HelpServerPort' -NewValue (Get-HelpServerPort -mainVersion $SetupParameters.mainVersion)
    Set-Content -Path $clientSettingsPath -Value $clientUserSettings.OuterXml -Force

    $ClientSettings = New-Object -TypeName PSObject
    $ClientSettings | Add-Member -MemberType NoteProperty -Name Client -Value $clientexe
    $ClientSettings | Add-Member -MemberType NoteProperty -Name Config -Value $clientSettingsPath
    return $ClientSettings
}