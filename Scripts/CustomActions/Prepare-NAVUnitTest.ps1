Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name
} else {    
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    $CompanyRegistrationNo = Initialize-NAVTestCompany -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    UnLoad-InstanceAdminTools
}