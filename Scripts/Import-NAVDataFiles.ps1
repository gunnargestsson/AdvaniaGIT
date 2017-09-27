Import-Module 'C:\Program Files\Microsoft Dynamics NAV\90\Service\NavAdminTool.ps1'

$Settings = Get-Item -Path D:\PUB2016.json
$ServerInstance = Get-NAVServerInstance

$Tenants = Get-Content -Path $Settings.FullName -Encoding UTF8 | Out-String | ConvertFrom-Json
foreach ($Tenant in $Tenants) {
    Write-Host "Importing Tenant $($Tenant.'Tenant ID')..."
    $NAVData = "D:\$($Tenant.'Tenant ID').navdata"
    Import-NAVData -ServerInstance $ServerInstance.ServerInstance -Tenant $Tenant.'Tenant ID' -FilePath $NAVData -IncludeGlobalData -AllCompanies -Force
}