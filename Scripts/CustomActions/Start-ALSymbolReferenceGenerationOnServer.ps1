if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Enable-NAVServerGenerateSymbolReferences -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}


