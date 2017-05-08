Load-InstanceAdminTools -SetupParameters $SetupParameters
Load-AppsManagementTools  -SetupParameters $Setupparameters
$DefaultInstance = Get-DefaultInstanceName -SetupParameters $SetupParameters -BranchSettings $BranchSettings

Unpublish-NAVApp `
  -ServerInstance $DefaultInstance `
  -Name $SetupParameters.appManifestName
     
Write-Host "$($SetupParameters.appName) unpublished from server $DefaultInstance"
UnLoad-AppsManagementTools
UnLoad-InstanceAdminTools