Check-GitNotUnattached
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-AppsTools -SetupParameters $SetupParameters
    if (Test-Path $PermissionSetsPath) 
    {
      Remove-Item -Path $PermissionSetsPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -Path $PermissionSetsPath -ItemType Directory | Out-Null

    foreach ($set in $SetupParameters.permissionSets) {
        $setId = $set | Select-Object id
        $setDesc = $set | Select-Object description
        $PermissionFilePath = (Join-Path $PermissionSetsPath ($setId.id + ".xml").Replace('\','_').Replace('/','_').Replace(':','_'))
   
        Export-NAVAppPermissionSet `
            -ServerInstance $BranchSettings.instanceName `
            -Path $PermissionFilePath `
            -PermissionSetId $setId.id `
            -Force
        Write-Host "Created File: $PermissionFilePath"
    }
    UnLoad-AppsTools
}