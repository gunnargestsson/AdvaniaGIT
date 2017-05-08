Load-AppsManagementTools  -SetupParameters $SetupParameters
$BaseSetupParameters = Get-BaseBranchSetupParameters -SetupParameters $SetupParameters
$BaseBranchSettings = Get-BranchSettings -SetupParameters $BaseSetupParameters
Check-NAVServiceRunning -SetupParameters $BaseSetupParameters -BranchSettings $BaseBranchSettings

Unpublish-NAVApp `
  -ServerInstance $BaseBranchSettings.instanceName `
  -Name $SetupParameters.appManifestName
      

Write-Host "$($SetupParameters.appName) unpublished from server $($BaseBranchSettings.instanceName)"
UnLoad-AppsManagementTools
UnLoad-InstanceAdminTools