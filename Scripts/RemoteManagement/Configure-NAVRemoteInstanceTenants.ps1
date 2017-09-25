Function Configure-NAVRemoteInstanceTenants {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )

    do {
        Write-Host "Loading Remote Tenant Menu..."   
        
        $menuItems = Load-NAVRemoteInstanceTenantsMenu -SelectedInstance $SelectedInstance
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, Id, DatabaseName, CustomerName, LicenseNo, PasswordId, ClickOnceHost, State -AutoSize 
        $input = Read-Host "Please select tenant number (0 = exit, - = configure applicaion, + = new tenant)"
        switch ($input) {
            '0' { break }
            '-' { Configure-NAVRemoteInstanceApplication -Session $Session -Credential $Credential -DeploymentName $DeploymentName -SelectedInstance $SelectedInstance }
            '+' { New-NAVDeploymentRemoteInstanceTenant -Credential $Credential -DeploymentName $DeploymentName -SelectedInstance $SelectedInstance }
            default {
                $selectedTenant = $menuItems | Where-Object -Property No -EQ $input                
                if ($selectedTenant) {                    
                    Configure-NAVRemoteInstanceTenant -Session $Session -SelectedInstance $SelectedInstance -SelectedTenant $selectedTenant -DeploymentName $DeploymentName -Credential $Credential
                }
            }
        }                       
    }
    until ($input -iin ('0','+'))
    
}