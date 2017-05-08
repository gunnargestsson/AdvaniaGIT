if ($BranchSettings.instanceName -ne "") {
    Write-Host "Requesting removal of NAV Environment for branch" $Setupparameters.Branchname
    Load-InstanceAdminTools -SetupParameters $Setupparameters
    Remove-NAVEnvironment -BranchSettings $BranchSettings
    UnLoad-InstanceAdminTools
}

