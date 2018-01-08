if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    foreach ($Tenant in Get-NAVTenant -ServerInstance $InstanceName) {
        Write-Host "Running Force Sync for $($Tenant.Id)..."
        Sync-NAVTenant -ServerInstance $InstanceName -Tenant $Tenant.Id -Mode ForceSync -Force
    }
    UnLoad-InstanceAdminTools
}