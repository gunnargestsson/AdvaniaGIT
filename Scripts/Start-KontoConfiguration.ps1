# Import all needed modules
Get-Module AdvaniaGIT | Remove-Module
Get-Module RemoteManagement | Remove-Module
Get-Module KontoManagement | Remove-Module
Import-Module RemoteManagement -DisableNameChecking | Out-Null
Import-Module AdvaniaGIT -DisableNameChecking | Out-Null
Import-Module KontoManagement -DisableNameChecking | Out-Null
Import-Module AzureRM
Import-Module AzureAD
   
# Get Environment Settings
$SetupParameters = Get-GITSettings
$RemoteConfig = Get-NAVRemoteConfig
$KontoConfig = Get-NAVKontoConfig

do {
    # Start Menu
    $menuItems = Load-NAVKontoStartMenu -KontoConfig $KontoConfig
    Clear-Host
    For ($i=0; $i -le 10; $i++) { Write-Host "" }
    $menuItems | Format-Table -Property No, Deployment, Description -AutoSize 
    $input = Read-Host "Please select provider number (0 = exit)"
    switch ($input) {
        '0' { break }
        default {
            $selectedProvider = $menuItems | Where-Object -Property No -EQ $input
            if ($selectedProvider) { 
                Configure-NAVKontoProvider -Provider $selectedProvider
            }
        }
    }
}
until ($input -ieq '0')
