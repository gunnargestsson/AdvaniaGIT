Function Configure-NAVRemoteInstanceTenantCompanies {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
    PROCESS
    {
        do {
        Write-Host "Loading Remote Tenant Company Menu..."   
        $menuItems = Load-NAVRemoteInstanceTenantCompanyMenu -Session $Session  -SelectedTenant $SelectedTenant
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, CompanyName, EvaluationCompany -AutoSize 
        $input = Read-Host "Please select company number (0 = exit, + = new company)"
        switch ($input) {
            '0' { break }
            '+' {
                    try {
                        $NewCompany = New-NAVRemoteInstanceTenantCompany -Session $Session -SelectedTenant $SelectedTenant -Credential $Credential -DeploymentName $DeploymentName 
                        if ($NewCompany.OKPressed -eq 'OK') { Write-Host "Company $($NewCompany.CompanyName) created" }
                    }
                    catch {
                        Write-Host -ForegroundColor Red "Failed to create new Companys!"
                    }
                    finally {
                        $anyKey = Read-Host "Press enter to continue..."
                    }
                }
            default {
                $selectedCompany = $menuItems | Where-Object -Property No -EQ $input                
                if ($selectedCompany) {
                    do {
                        Clear-Host
                        For ($i=0; $i -le 10; $i++) { Write-Host "" }
                        $selectedCompany | Format-Table -Property CompanyName, EvaluationCompany  -AutoSize 
                        $input = Read-Host "Please select action:`
    0 = exit, `
    1 = rename, `
    2 = remove, `
    Action: "

                        switch ($input) {
                            '0' { break }
                            '1' { 
                                    try {
                                        $UpdatedCompany = Rename-NAVRemoteInstanceTenantCompany -Session $Session -SelectedTenant $SelectedTenant -SelectedCompany $selectedCompany 
                                    }
                                    catch {
                                        Write-Host -ForegroundColor Red "Error updating Company $($selectedCompany.CompanyName)"
                                    }
                                    finally {
                                        $anyKey = Read-Host "Press enter to continue..."
                                    }
                                }
                            '2' { 
                                    try {
                                        $UpdatedCompany = Remove-NAVRemoteInstanceTenantCompany -Session $Session -SelectedTenant $SelectedTenant -SelectedCompany $selectedCompany
                                    }
                                    catch {
                                        Write-Host -ForegroundColor Red "Error removing Company $($selectedCompany.CompanyName)"
                                    }
                                    finally {
                                        $anyKey = Read-Host "Press enter to continue..."
                                    }
                                }
                        }                    
                    }
                    until ($input -iin ('0','1','2','3'))
                }
            }
        }
                    
    }
    until ($input -ieq '0')
    }
}