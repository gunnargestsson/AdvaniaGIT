Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-ModelTools -SetupParameters $SetupParameters
    Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path (Join-Path $SetupParameters.workFolder 'Target.txt') -ImportAction Overwrite -SynchronizeSchemaChanges Force        
    UnLoad-ModelTools
}