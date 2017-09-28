Function Configure-NAVRemoteInstanceTenant {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
    do {
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $SelectedTenant | Format-Table -Property Id, DatabaseName, CustomerName, LicenseNo, PasswordId, ClickOnceHost, State -AutoSize 
        $input = Read-Host "Please select action:`
    0 = Exit, `
    1 = Tenant Companies, `
    2 = Tenant Users, `
    3 = Tenant Configuration, `
    4 = Tenant Settings, `
    5 = Create/Update Tenant ClickOnce, `
    6 = Update Tenant License, `
    7 = Remove Tenant `
    Action "

        switch ($input) {
            '0' { break }
            '1' { Configure-NAVRemoteInstanceTenantCompanies -Session $Session -SelectedTenant $SelectedTenant -DeploymentName $DeploymentName -Credential $Credential }
            '2' { Configure-NAVRemoteInstanceTenantUsers -Session $Session -SelectedTenant $SelectedTenant -DeploymentName $DeploymentName -Credential $Credential }
            '3' { 
                    if ($SelectedInstance.Multitenant -eq "true") {
                        Write-Host -ForegroundColor Red "To update tenant configureation, remove tenant and mount it again"
                        $anyKey = Read-Host "Press enter to continue..."                        
                    } else {
                        Configure-NAVRemoteInstanceDatabase -Session $Session -SelectedInstance $SelectedInstance -DeploymentName $DeploymentName -Credential $Credential
                    }
                }
            '4' { 
                    $NewSelectedTenant = Configure-NAVRemoteInstanceTenantSettings -Session $Session -Credential $Credential -DeploymentName $DeploymentName -SelectedTenant $SelectedTenant 
                    $TenantSettings = Get-NAVRemoteInstanceTenantSettings -Session $Session -SelectedTenant $SelectedTenant
                    $SelectedTenant = Combine-Settings $TenantSettings $SelectedTenant
                }
            '5' { 
                    New-NAVDeploymentRemoteClickOnceSite -Credential $Credential -DeploymentName $DeploymentName -SelectedInstance $SelectedInstance -SelectedTenant $SelectedTenant 
                    $anyKey = Read-Host "Press enter to continue..."
                }
            '6' { 
                    Set-NAVDeploymentRemoteInstanceTenantLicense -Session $Session -Credential $Credential -DeploymentName $DeploymentName -SelectedTenant $SelectedTenant
                    $anyKey = Read-Host "Press enter to continue..."
                }
            '7' { 
                    if ($SelectedInstance.Multitenant -eq "true") {
                        Dismount-NAVRemoteInstanceTenant -Session $Session -SelectedTenant $SelectedTenant 
                    } else {
                        Remove-NAVDeploymentRemoteInstance -Credential $Credential -SelectedInstance $SelectedInstance -DeploymentName $DeploymentName 
                    }
                }
        }                    
    }
    until ($input -iin ('0', '7'))        
}