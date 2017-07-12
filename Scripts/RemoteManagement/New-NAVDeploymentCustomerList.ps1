Function New-NAVDeploymentCustomerList {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    {    
        $TenantListFileName = Join-Path $env:TEMP "${Deployment}TenantList.csv" 
        Remove-Item -Path $TenantListFileName -Force -ErrorAction SilentlyContinue
        if (Test-Path $TenantListFileName) {
            Write-Host -ForegroundColor Red "${TenantListFileName} exists and is locked by Excel!"
            $anyKey = Read-Host "Press enter to continue..."
            break
        }

        Write-Host "Loading Instances for $DeploymentName..."

        $RemoteConfig = Get-NAVRemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        $Instances = Load-NAVRemoteInstanceMenu -Credential $Credential -RemoteConfig $RemoteConfig -DeploymentName $DeploymentName
        Foreach ($SelectedInstance in $Instances) {
            Foreach ($SelectedTenant in $SelectedInstance.TenantList) {
                $SelectedTenant | Add-Member -MemberType NoteProperty -Name DeploymentName -Value $DeploymentName
                $SelectedTenant | Add-Member -MemberType NoteProperty -Name PublicODataBaseUrl -Value "$($SelectedInstance.PublicODataBaseUrl)?tenant=$($SelectedTenant.Id)"
                $SelectedTenant | Add-Member -MemberType NoteProperty -Name PublicSOAPBaseUrl -Value "$($SelectedInstance.PublicSOAPBaseUrl)?tenant=$($SelectedTenant.Id)"
                $SelectedTenant | Add-Member -MemberType NoteProperty -Name PublicWebBaseUrl -Value "$($SelectedInstance.PublicWebBaseUrl)?tenant=$($SelectedTenant.Id)"
                $SelectedTenant | Add-Member -MemberType NoteProperty -Name PublicWinBaseUrl -Value "$($SelectedInstance.PublicWinBaseUrl)?tenant=$($SelectedTenant.Id)"
                $SelectedTenant | Add-Member -MemberType NoteProperty -Name ClientServicesPort -Value $SelectedInstance.ClientServicesPort
                $SelectedTenant | Add-Member -MemberType NoteProperty -Name ClientServicesCredentialType -Value $SelectedInstance.ClientServicesCredentialType
                $SelectedTenant | Select-Object State,DeploymentName,ServerInstance,Id,CustomerRegistrationNo,CustomerName,CustomerEMail,PasswordId,LicenseNo,ClickOnceHost,PublicODataBaseUrl,PublicSOAPBaseUrl,PublicWebBaseUrl,PublicWinBaseUrl,DatabaseName,DatabaseServer,ClientServicesPort,ClientServicesCredentialType |
                Export-Csv -Path $TenantListFileName -Encoding UTF8 -UseCulture -NoTypeInformation -Append                
            }
        }
        Start-Process $TenantListFileName
    }
}