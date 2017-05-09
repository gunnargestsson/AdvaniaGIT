Get-Module -Name AdvaniaGIT | Remove-Module
Get-Module -Name Cloud.Ready.Software.NAV | Remove-Module
. (Join-Path $PSScriptRoot 'Start-CustomAction.ps1') "C:\NAVManagementWorkFolder\Workspace\GIT\Advania\nav2016" "Start-Client.ps1" $false


#Import-Module AdvaniaGIT




#Get-FtpDirectory -Server $GitSettings.ftpServer -User $GitSettings.ftpUser -Pass $GitSettings.ftpPass -Directory "2017/"


