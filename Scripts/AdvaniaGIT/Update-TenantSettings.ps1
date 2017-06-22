function Update-TenantSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Tenant,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = "Data\TenantSettings.Json"
    )
    $allTenantSettings = Get-Content -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath) | Out-String | ConvertFrom-Json
    $newTenantSettings = @()
    $allTenantSettings.Tenants | foreach { if ($_.ServerInstance -ne $Tenant.ServerInstance -and $_Id -ne $Tenant.Id) {$newTenantSettings += $_}}
    $TenantSettings = @{
            "Id" = $Tenant.Id; 
            "ServerInstance" = $Tenant.ServerInstance;
            "CustomerRegistrationNo" = $Tenant.CustomerRegistrationNo; 
            "CustomerName" = $Tenant.CustomerName; 
            "CustomerEMail" = $Tenant.CustomerEMail;
            "PasswordId" = $Tenant.PasswordId;
            "LicenseNo" = $Tenant.LicenseNo;
            "ClickOnceHost" = $Tenant.ClickOnceUrl}    
    $newTenantSettings += $TenantSettings
    $allTenantSettings.Tenants = $newTenantSettings
    Set-Content -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath) -Value ($allTenantSettings | ConvertTo-Json)                
    Return $TenantSettings
}


