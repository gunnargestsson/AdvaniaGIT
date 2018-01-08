if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    foreach ($Tenant in Get-NAVTenant -ServerInstance $BranchSettings.instanceName) {
        Write-Host "Running Force Sync for $($Tenant.Id)..."
        Sync-NAVTenant -ServerInstance $BranchSettings.instanceName -Tenant $Tenant.Id -Mode ForceSync -Force
    }
    UnLoad-InstanceAdminTools
}