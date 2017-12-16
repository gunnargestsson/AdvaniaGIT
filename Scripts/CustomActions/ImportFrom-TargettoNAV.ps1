Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-ModelTools -SetupParameters $SetupParameters
    
    Write-Verbose -Message "Importing from Target.txt on $($BranchSettings.managementPort)/$($BranchSettings.instanceName)"
    $logFile = (Join-Path $SetupParameters.LogPath "navimport.log")
    $Path = (Join-Path $SetupParameters.workFolder 'Target.txt')
    $command = "Command=ImportObjects`,ImportAction=Overwrite`,SynchronizeSchemaChanges=Force`,File=`"$Path`""                 

    Run-NavIdeCommand -SetupParameters $SetupParameters `
                        -BranchSettings $BranchSettings `
                        -Command $command `
                        -LogFile $logFile `
                        -ErrText "Error while importing from $(Split-Path $Path)" `
                        -Verbose:$VerbosePreference

          
    UnLoad-ModelTools
}