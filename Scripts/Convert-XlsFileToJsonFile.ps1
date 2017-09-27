# Import all needed modules
Get-Module AdvaniaGIT | Remove-Module
Import-Module AdvaniaGIT -DisableNameChecking | Out-Null

$XlsFileName = Get-Item -Path C:\NAVManagementWorkFolder\Workspace\PUB2016.xlsx
$JsonContent = ConvertTo-XslToJson -XlsFilePath $XlsFileName
Set-Content -Path C:\NAVManagementWorkFolder\Workspace\PUB2016.json -Value $JsonContent -Encoding UTF8

