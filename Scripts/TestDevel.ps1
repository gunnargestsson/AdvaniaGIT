Get-Module -Name AdvaniaGIT | Remove-Module
#. (Join-Path $PSScriptRoot 'Start-CustomAction.ps1') "C:\NAVManagementWorkFolder\Workspace\GIT\Advania\NAV2017" "Create-NAVBacpac.ps1" $false $false 
#. (Join-Path $PSScriptRoot 'Start-CustomAction.ps1') "C:\NAVManagementWorkFolder\Workspace\GIT\Kappi\NAV2017" "Upgrade-NAVInstallation" $false
#. (Join-Path $PSScriptRoot 'Start-CustomAction.ps1') "C:\NAVManagementWorkFolder\Workspace\GIT\Advania\NAV2017" "Update-NAVSource.ps1" $false
. (Join-Path $PSScriptRoot 'Start-CustomAction.ps1') "C:\NAVManagementWorkFolder\Workspace\GIT\Advania\NAV2016" "Dummy-Action.ps1" $false
#. (Join-Path $PSScriptRoot 'Start-CustomAction.ps1') "C:\NAVManagementWorkFolder\Workspace\GIT\Advania\NAV2016" "Manage-Instances.ps1" $false
#. (Join-Path $PSScriptRoot 'Start-CustomAction.ps1') "C:\NAVManagementWorkFolder\Workspace\GIT\Advania\NAV2016" "Manage-Databases.ps1" $false
#. (Join-Path $PSScriptRoot 'Start-CustomAction.ps1') "C:\NAVManagementWorkFolder\Workspace\GIT\Advania\NAV2016" "Build-DeltasInGIT.ps1" $false

#Load-InstanceAdminTools -SetupParameters $SetupParameters

