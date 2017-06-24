# Import all needed modules
Get-Module RemoteManagement | Remove-Module
Import-Module RemoteManagement -DisableNameChecking | Out-Null
Get-Module AdvaniaGIT | Remove-Module
Import-Module AdvaniaGIT -DisableNameChecking | Out-Null
Import-Module AzureRM
   
# Get Environment Settings
$SetupParameters = Get-GITSettings
$RemoteConfig = Get-RemoteConfig

$VMAdmin = Get-PasswordStateUser -PasswordId $RemoteConfig.VMUserPasswordID
if ($VMAdmin.UserName -gt "" -and $VMAdmin.Password -gt "") {
    $Credential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))
} else {
    $Credential = Get-Credential -Message "Remote Login to Hosts" -ErrorAction Stop    
}

if (!$Credential.UserName -or !$Credential.Password) {
    Write-Host -ForegroundColor Red "Credentials required!"
    break
}

$AzureRMAdmin = Get-PasswordStateUser -PasswordId $RemoteConfig.AzureRMUserPasswordID
if ($AzureRMAdmin.UserName -gt "" -and $AzureRMAdmin.Password -gt "") {
    $AzureCredential = New-Object System.Management.Automation.PSCredential($AzureRMAdmin.UserName, (ConvertTo-SecureString $AzureRMAdmin.Password -AsPlainText -Force))
} else {
    $AzureCredential = Get-Credential -Message "Remote Login to Azure Dns" -ErrorAction Stop    
}

if (!$AzureCredential.UserName -or !$AzureCredential.Password) {
    Write-Host -ForegroundColor Red "Azure Credentials required!"
    break
}

$Login = Login-AzureRmAccount -Credential $AzureCredential
$Subscription = Select-AzureRmSubscription -SubscriptionName $RemoteConfig.AzureRMSubscriptionName -ErrorAction Stop

do {
    # Start Menu
    $menuItems = Load-StartMenu -RemoteConfig $RemoteConfig
    Clear-Host
    For ($i=0; $i -le 10; $i++) { Write-Host "" }
    $menuItems | Format-Table -Property No, Deployment, Description -AutoSize 
    $input = Read-Host "Please select deployment number (0 = exit)"
    switch ($input) {
        '0' { break }
        default {
            $selectedDeployment = $menuItems | Where-Object -Property No -EQ $input
            if ($selectedDeployment) { 
                do {   
                    Clear-Host
                    For ($i=0; $i -le 10; $i++) { Write-Host "" }
                    $selectedDeployment | Format-Table -Property Deployment, Description -AutoSize 
                    $input = Read-Host "Please select action (1 = configure, 0 = exit)"
                    switch ($input) {
                        '0' { break }
                        '1' {
                                Write-Verbose "Start instances menu"
                                Configure-NAVRemoteInstances -Credential $Credential -RemoteConfig $RemoteConfig -DeploymentName $selectedDeployment.Deployment
                            }
                    }
                }
                until ($input -iin ('0', '1'))
            }
        }
    }
}
until ($input -ieq '0')
