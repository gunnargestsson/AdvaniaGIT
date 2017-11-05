Function Start-NAVRemoteUnitTestsOnDockerContainer
{
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )

    Invoke-Command -Session $Session -ScriptBlock `
    {
        $Session = New-DockerSession -DockerContainerId $BranchSettings.DockerContainerId
        $CompanyRegistrationNo = Invoke-Command -Session $Session -ScriptBlock `
        {            
            Import-Module AdvaniaGIT -DisableNameChecking | Out-Null
            $SetupParameters = Get-GITSettings
            $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters

            if ($SetupParameters.testCompanyName) {
                $companyName = $SetupParameters.testCompanyName
            } else {
                $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
            }
            $CompanyRegistrationNo = Initialize-NAVTestCompanyRegistrationNo -BranchSettings $BranchSettings -CompanyName $companyName
            Prepare-NAVTestExecution -BranchSettings $BranchSettings -CompanyName $companyName 
            Load-InstanceAdminTools -SetupParameters $SetupParameters
            Initialize-NAVTestCompany -SetupParameters $SetupParameters -BranchSettings $BranchSettings
            UnLoad-InstanceAdminTools
            return $CompanyRegistrationNo
 
        }

        [xml]$clientUserSettings = Invoke-Command -Session $Session -ScriptBlock `
        {            
            [xml]$clientUserSettings = Get-Content -Path 'C:\Run\ClientUserSettings.config'
            Import-Module AdvaniaGIT -DisableNameChecking | Out-Null
            $SetupParameters = Get-GITSettings
            $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
            Load-InstanceAdminTools -SetupParameters $SetupParameters
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
            UnLoad-InstanceAdminTools
            Return $ClintUserSettings
        }
        $clientSettingsPath = (Join-Path $SetupParameters.LogPath 'ClientUserSettings.config')
        Set-Content -Path $clientSettingsPath -Value $clientUserSettings.OuterXml -Force

        $clientexe = (Join-Path $SetupParameters.LogPath 'RoleTailored Client\Microsoft.Dynamics.Nav.Client.exe')    
        Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings

        if ($SetupParameters.testCodeunitId -and $SetupParameters.testCodeunitId -gt "") {
            $CodeunitId = $SetupParameters.testCodeunitId
        } else {
            $CodeunitId = 130402
        }

        $params = @()
        $params += @("-consolemode -showNavigationPage:0 -settings:`"$clientSettingsPath`" `"dynamicsnav://///RunCodeunit?Codeunit=$CodeunitId`"")
        $startDate = Get-Date 
        Write-Host "Running: `"$clientexe`" $params" -ForegroundColor Green
        Start-Process -FilePath $clientexe -ArgumentList $params -Wait


        Invoke-Command -Session $Session -ScriptBlock `
        {            
            param([string]$CompanyRegistrationNo,[datetime]$startDate)
            Import-Module AdvaniaGIT -DisableNameChecking | Out-Null
            $SetupParameters = Get-GITSettings
            $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters

            Set-NAVCompanyInfoRegistrationNo -BranchSettings $BranchSettings -CompanyName $companyName -RegistrationNo $CompanyRegistrationNo

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

        } -ArgumentList ($CompanyRegistrationNo, $startDate)

        Remove-PSSession $Session
    }
}