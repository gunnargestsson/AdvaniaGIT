Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
Write-Host "Requesting new NAV bacpac for branch" $SetupParameters.Branchame
Write-Host "Removing NAV License from database before backing up..."
Remove-NAVDatabaseLicense -BranchSettings $BranchSettings
Load-InstanceAdminTools -SetupParameters $SetupParameters
Set-NAVServerInstance -ServerInstance $BranchSettings.instanceName -Stop -Force
Create-NAVDatabaseBacpac -SetupParameters $SetupParameters -BranchSettings $BranchSettings
Set-NAVServerInstance -ServerInstance $BranchSettings.instanceName -Start -Force -ErrorAction Stop
if (Test-Path $SetupParameters.LicenseFilePath) {  
    Update-NAVLicense -BranchSettings $BranchSettings -LicenseFilePath $SetupParameters.LicenseFilePath 
}
UnLoad-InstanceAdminTools 
