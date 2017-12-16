Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-ModelTools -SetupParameters $SetupParameters
    
    Write-Verbose -Message "Importing from Target.txt on $($BranchSettings.managementPort)/$($BranchSettings.instanceName)"
    $logFile = (Join-Path $SetupParameters.LogPath "navimport.log")
    $command = "Command=ImportObjects`,ImportAction=Overwrite`,SynchronizeSchemaChanges=Force`,File=`"(Join-Path $SetupParameters.workFolder 'Target.txt')`""                 

    Run-NavIdeCommand -SetupParameters $SetupParameters `
                        -BranchSettings $BranchSettings `
                        -Command $command `
                        -LogFile $logFile `
                        -ErrText "Error while importing from $(Split-Path $Path)" `
                        -Verbose:$VerbosePreference

          
    UnLoad-ModelTools
}