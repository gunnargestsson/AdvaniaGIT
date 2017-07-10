Function Configure-NAVRemoteInstanceDatabase {
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
    PROCESS
    {
        do {
        Write-Host "Loading Remote Tenant Database Menu..."   
        $menuItems = Load-NAVRemoteInstanceDatabaseMenu -Session $Session -SelectedInstance $selectedInstance
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property DatabaseName, DatabaseServerName, DatabaseServerInstance, DatabaseUserName -AutoSize 
        $input = Read-Host "Please select user number (0 = Exit, 1 = Update Service Configuration)"
        switch ($input) {
            '0' { break }
            '1' {                    
                    try {
                        $Database = Set-NAVDeploymentRemoteInstanceDatabase -Session $Session -SelectedInstance $selectedInstance -Database $menuItems -DeploymentName $DeploymentName -Credential $Credential
                        if ($Database.OKPressed -eq $true) { Write-Host "Database settings updated" }
                    }
                    catch {
                        Write-Host -ForegroundColor Red "Failed to update database settings!"
                    }
                    finally {
                        $anyKey = Read-Host "Press enter to continue..."
                    }
                }
            }
        }
        until ($input -ieq '0')
        }
}