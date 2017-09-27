Import-Module 'C:\Program Files\Microsoft Dynamics NAV\90\Service\NavAdminTool.ps1'
$ServerInstance = "ADIS2016W"
$ftpPath = "ftp://advaniatok2016-01.westeurope.cloudapp.azure.com/"

$Settings = Get-Item -Path C:\AdvaniaGIT\Workspace\PUB2016.json
$Tenants = Get-Content -Path $Settings.FullName -Encoding UTF8 | Out-String | ConvertFrom-Json
foreach ($Tenant in $Tenants) {
    $NAVData = "C:\AdvaniaGIT\Backup\$($Tenant.'Tenant ID').navdata"
    Export-NAVData -ServerInstance $ServerInstance -Tenant $Tenant.'Tenant ID' -FilePath $NAVData -IncludeGlobalData -AllCompanies -Force
    Put-FtpFile -Server $ftpPath -User "anonymous" -Pass "gg@advania.is" -FtpFilePath "$($Tenant.'Tenant ID').navdata" -LocalFilePath $NAVData
}
Put-FtpFile -Server $ftpPath -User "anonymous" -Pass "gg@advania.is" -FtpFilePath $Settings.Name -LocalFilePath $Settings.FullName