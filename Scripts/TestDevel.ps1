Get-Module -Name AdvaniaGIT | Remove-Module
. (Join-Path $PSScriptRoot 'Start-CustomAction.ps1') "C:\NAVManagementWorkFolder\Workspace\GIT\Advania\nav2016" "Build-Target.ps1" $false
