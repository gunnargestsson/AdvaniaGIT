if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    $UserExists = Get-NAVServerUser -ServerInstance $BranchSettings.instanceName | Where-Object -Property UserName -Match "\w+\\$($env:USERNAME)"
    if ($UserExists -eq $null) {
        New-NAVServerUser -ServerInstance $BranchSettings.instanceName -WindowsAccount $env:USERNAME
        New-NAVServerUserPermissionSet -ServerInstance $BranchSettings.instanceName -WindowsAccount $env:USERNAME -PermissionSetId SUPER
    }
    Initialize-NAVTestCompany -SetupParameters $SetupParameters -BranchSettings $BranchSettings -RestartService
    UnLoad-InstanceAdminTools
}