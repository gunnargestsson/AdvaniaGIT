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
        $selectedTenant | Format-Table -Property Id, DatabaseName, CustomerName, LicenseNo, PasswordPid, State -AutoSize 
        $input = Read-Host "Please select action:`
    0 = exit, `
    1 = users, `
    2 = database, `
    2 = ClickOnce, `
    Action: "

        switch ($input) {
            '0' { break }
            '1' { Configure-NAVRemoteInstanceTenantUsers -Session $Session -SelectedTenant $selectedTenant }
            '2' { 
                    if ($SelectedInstance.Multitenant -eq "true") {
                        #Configure-NAVRemoteInstanceTenantDatabase -Session $Session -SelectedTenant $selectedTenant -DeploymentName $DeploymentName -Credential $Credential}
                    } else {
                        Configure-NAVRemoteInstanceDatabase -Session $Session -SelectedInstance $selectedInstance -DeploymentName $DeploymentName -Credential $Credential}                        
                    }
            
        }                    
    }
    until ($input -iin ('0', '1', '2'))        
}