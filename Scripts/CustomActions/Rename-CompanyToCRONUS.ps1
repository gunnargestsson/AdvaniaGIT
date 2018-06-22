
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-InstanceAdminTools -SetupParameters $SetupParameters 
    $CompanyName = (Get-NAVCompany $BranchSettings.instanceName)[0]
    if ($CompanyName -cnotmatch "CRONUS") {
        Rename-NAVCompany -CompanyName $CompanyName -NewCompanyName "CRONUS ${CompanyName}" -ServerInstance $BranchSettings.instanceName -Force
    }            
}
