if ($SetupParameters.storeAllObjects -eq "false" -or $SetupParameters.storeAllObjects -eq $false) {
    Write-Host -ForegroundColor Red "This action does not support branches not storing all objects!"
    $anyKey = Read-Host "Press enter to continue..."
    break
}

if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name
} else {    
    Load-ModelTools -SetupParameters $SetupParameters
    $ObjectFileName = (Join-Path $SetupParameters.workFolder 'Source.txt')
    if (Test-Path $ObjectFileName)
    {
        Remove-Item -Path $ObjectFileName  -Force
    }
    Join-NAVApplicationObjectFile -Source (Join-Path $SetupParameters.NewSyntaxObjectsPath '*.txt') -Destination $ObjectFileName -Force
    UnLoad-ModelTools
}