Function Manage-NAVRemoteInstances {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$RemoteConfig,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
        
    do {
        Write-Host "Loading Remote Instance Menu..."   
        $menuItems = Load-NAVRemoteInstanceMenu -Credential $Credential -RemoteConfig $RemoteConfig -DeploymentName $DeploymentName -IncludeAllHosts
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, HostName, ServerInstance, DatabaseName, Multitenant, Version, State -AutoSize 
        $input = Read-Host "Please select instance number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedInstanceName = ($menuItems | Where-Object -Property No -EQ $input).ServerInstance
                $selectedInstance = $menuItems | Where-Object -Property ServerInstance -EQ $selectedInstanceName
                if ($selectedInstance) {
                    do {
                        Clear-Host
                        For ($i=0; $i -le 10; $i++) { Write-Host "" }
                        $selectedInstance | Format-Table -Property No, HostName, ServerInstance, DatabaseName, Multitenant, Version, State -AutoSize 
                        $input = Read-Host "Please select action:`
    0 = Exit, `
    1 = Start Force Sync, `
    2 = Start Normal Sync, `
    3 = Start Service, `
    4 = Stop Service, `
    5 = View Service Event Log, `
    6 = View Service Sessions, `
    7 = Data Upgrade Menu, `
    Select action"
                        switch ($input) {
                            '0' { break }
                            '1' { Start-NAVRemoteInstanceForceSync -Credential $Credential -SelectedInstances $selectedInstance }
                            '2' { Start-NAVRemoteInstanceSync -Credential $Credential -SelectedInstances $selectedInstance }
                            '3' { Start-NAVDeploymentRemoteInstance -Credential $Credential -SelectedInstances $selectedInstance }
                            '4' { Stop-NAVDeploymentRemoteInstance -Credential $Credential -SelectedInstances $selectedInstance }
                            '5' { Get-NAVRemoteInstanceEvents -Credential $Credential -SelectedInstances $selectedInstance }
                            '6' { Get-NAVRemoteInstanceSessions -Credential $Credential -SelectedInstance $selectedInstance[0] }
                            '7' { Manage-NAVRemoteInstanceDataUpgrade -Credential $Credential -SelectedInstance $selectedInstance[0] }
                        }                    
                    }
                    until ($input -iin ('0'))
                }
            }
        }
                    
    }
    until ($input -ieq '0')
    
}