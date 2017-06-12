Get-Module -Name AdvaniaGIT | Remove-Module
#. (Join-Path $PSScriptRoot 'Start-CustomAction.ps1') "C:\NAVManagementWorkFolder\Workspace\GIT\Advania\NAV2017" "Create-NAVBacpac.ps1" $false $false "C:\\NAVManagementWorkFolder\\Temp"
#. (Join-Path $PSScriptRoot 'Start-CustomAction.ps1') "C:\NAVManagementWorkFolder\Workspace\GIT\Kappi\NAV2016" "Upgrade-NAVInstallation" $false
. (Join-Path $PSScriptRoot 'Start-CustomAction.ps1') "C:\NAVManagementWorkFolder\Workspace\GIT\Advania\NAV2017" "Update-NAVSource.ps1" $false
#. (Join-Path $PSScriptRoot 'Start-CustomAction.ps1') "C:\NAVManagementWorkFolder\Workspace\GIT\Advania\NAV2017" "Dummy-Action.ps1" $false
