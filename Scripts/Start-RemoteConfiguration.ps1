# Import all needed modules
Get-Module RemoteManagement | Remove-Module
Import-Module RemoteManagement -DisableNameChecking | Out-Null
Get-Module AdvaniaGIT | Remove-Module
Import-Module AdvaniaGIT -DisableNameChecking | Out-Null
Import-Module AzureRM

$VMAdminUserName = 'navlightadmin'
$VMAdminPassword = 'tempt-v#JZc%'
$Credential = New-Object System.Management.Automation.PSCredential($VMAdminUserName, (ConvertTo-SecureString $VMAdminPassword -AsPlainText -Force))

#$Credential = Get-Credential -Message "Remote Login to Hosts" -ErrorAction Stop
if (!$Credential.UserName -or !$Credential.Password) {
    Write-Host -ForegroundColor Red "Credentials required!"
    break
}
   
# Get Environment Settings
$SetupParameters = Get-GITSettings
$RemoteConfig = Get-RemoteConfig

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
