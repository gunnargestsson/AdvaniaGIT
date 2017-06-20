function Get-TenantSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Tenant,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = "Data\TenantSettings.Json"
    )
    $instanceName = $Tenant.ServerInstance.Substring(27,$Tenant.ServerInstance.Length - 27)
    $allTenantSettings = Get-Content -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath) | Out-String | ConvertFrom-Json
    $TenantSettings = ($allTenantSettings.Tenants | Where-Object -Property ServerInstance -EQ $instanceName | Where-Object -Property Id -EQ $Tenant.Id)
    if ($TenantSettings -eq $null) {
        $TenantSettings = @{
            "Id" = $Tenant.Id; 
            "ServerInstance" = $instanceName;
            "CustomerRegistrationNo" = ""; 
            "CustomerName" = ""; 
            "CustomerEMail" = "";
            "PasswordPid" = "";
            "LicenseNo" = "";
            "ClickOnceUrl" = ""}
        $allTenantSettings.Tenants += $TenantSettings
        Set-Content -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath) -Value ($allTenantSettings | ConvertTo-Json)        
    }    
    Return $TenantSettings
}