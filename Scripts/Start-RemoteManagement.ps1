# Import all needed modules
Get-Module RemoteManagement | Remove-Module
Import-Module RemoteManagement -DisableNameChecking | Out-Null
Get-Module AdvaniaGIT | Remove-Module
Import-Module AdvaniaGIT -DisableNameChecking | Out-Null

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
                Write-Verbose "Start instances menu"
                List-NAVRemoteInstances -Credential $Credential -RemoteConfig $RemoteConfig -DeploymentName $selectedDeployment.Deployment                                 
            }
        }
    }
}
until ($input -ieq '0')
