if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    Load-AppsManagementTools  -SetupParameters $Setupparameters

    Get-NAVTenant -Serverinstance $BranchSettings.instanceName | Get-NAVAppInfo | Uninstall-NAVApp
     
    Write-Host "Extensions from server $($BranchSettings.instanceName)"
    UnLoad-AppsManagementTools
    UnLoad-InstanceAdminTools
}