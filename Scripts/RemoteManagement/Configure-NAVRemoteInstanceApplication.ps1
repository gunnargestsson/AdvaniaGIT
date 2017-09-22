Function Configure-NAVRemoteInstanceApplication {
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
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $SelectedTenant = New-Object -TypeName PSObject
        $SelectedTenant | Add-Member -MemberType NoteProperty -Name Id -Value default
        $SelectedTenant | Add-Member -MemberType NoteProperty -Name ServerInstance -Value $SelectedInstance.ServerInstance
        $SelectedTenant = Get-NAVRemoteInstanceTenantSettings -Session $Session -SelectedTenant $SelectedTenant       
        $SelectedTenant | Add-Member -MemberType NoteProperty -Name DatabaseName -Value $SelectedInstance.DatabaseName
        $SelectedTenant | Add-Member -MemberType NoteProperty -Name DatabaseServer -Value $SelectedInstance.DatabaseServer
        $SelectedTenant | Add-Member -MemberType NoteProperty -Name DatabaseServerInstance -Value $SelectedInstance.DatabaseServerInstance
        $SelectedTenant | Format-Table -Property Id, DatabaseName, LicenseNo -AutoSize 
        $input = Read-Host "Please select action:`
    0 = Exit, `
    1 = Application Configuration, `
    2 = Application Settings, `
    3 = Update Application License, `
    Action "

        switch ($input) {
            '0' { break }
            '1' { Configure-NAVRemoteInstanceDatabase -Session $Session -SelectedInstance $SelectedInstance -DeploymentName $DeploymentName -Credential $Credential }
            '2' { 
                    $NewSelectedTenant = Configure-NAVRemoteInstanceTenantSettings -Session $Session -Credential $Credential -DeploymentName $DeploymentName -SelectedTenant $SelectedTenant 
                    $TenantSettings = Get-NAVRemoteInstanceTenantSettings -Session $Session -SelectedTenant $SelectedTenant
                    $SelectedTenant = Combine-Settings $TenantSettings $SelectedTenant
                 }
            '3' {  
                    Set-NAVDeploymentRemoteInstanceTenantLicense -Session $Session -Credential $Credential -DeploymentName $DeploymentName -SelectedTenant $SelectedTenant
                    $anyKey = Read-Host "Press enter to continue..."
                }                
        }                    
    }
    until ($input -eq '0')        
}