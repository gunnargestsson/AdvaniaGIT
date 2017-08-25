Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name
} else {    
    [xml]$clientUserSettings = Get-Content -Path (Join-Path $env:ProgramData ('Microsoft\Microsoft Dynamics NAV\' + $SetupParameters.mainVersion + '\ClientUserSettings.config'))
    $clientSettingsPath = (Join-Path $SetupParameters.LogPath 'ClientUserSettings.config')
    $clientexe = (Join-Path $SetupParameters.navIdePath 'Microsoft.Dynamics.Nav.Client.exe')
    Edit-NAVClientUserSettings -ClientUserSettings $clientUserSettings -KeyName 'Server' -NewValue $env:COMPUTERNAME
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
    if ($SetupParameters.testCompanyName -and $SetupParameters.testCompanyName -gt "") {
        $companyName = $SetupParameters.testCompanyName
    } else {
        $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
    }
    if ($SetupParameters.testCodeunitId -and $SetupParameters.testCodeunitId -gt "") {
        $CodeunitId = $SetupParameters.testCodeunitId
    } else {
        $CodeunitId = 130402
    }

    $params = @()
    $params += @("-consolemode -showNavigationPage:0 -settings:`"$clientSettingsPath`" `"dynamicsnav:////$companyName/RunCodeunit?Codeunit=$CodeunitId`"")
    $startDate = Get-Date 
    Write-Host "Running: `"$clientexe`" $params" -ForegroundColor Green
    Start-Process -FilePath $clientexe -ArgumentList $params -Wait

    $ResultTableName = Get-DatabaseTableName -CompanyName $companyName -TableName 'CAL Test Result'
    $Command = "select count([No_]) as [No. of Tests],CASE [Result] WHEN 0 THEN 'Passed' WHEN 1 THEN 'Failed' WHEN 2 THEN 'Inconclusive' ELSE 'Incomplete' END as [Result] from [$ResultTableName] group by [Result]"
    $SqlResult = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $Command  
    Write-Host ''
    Write-Host "Results..."
    Write-Host ''
    $SqlResult | Format-Table
    $endDate = Get-Date
    Write-Host ''
    Write-Host "Started $startDate, ended $endDate, duration $(($endDate - $StartDate).ToString('g'))"
}