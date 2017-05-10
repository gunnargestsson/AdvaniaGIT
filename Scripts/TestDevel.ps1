Get-Module -Name AdvaniaGIT | Remove-Module
Get-Module -Name Cloud.Ready.Software.NAV | Remove-Module
. (Join-Path $PSScriptRoot 'Start-CustomAction.ps1') "C:\NAVManagementWorkFolder\Workspace\GIT\Advania\nav2016" "Clear-NAVCommentSection.ps1" $false
