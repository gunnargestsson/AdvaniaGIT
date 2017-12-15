Set-Location -Path $Repository

Check-GitNotUnattached
Check-GitCommitted

$sourcebranch = git.exe rev-parse --abbrev-ref HEAD 
Write-Host Save Source Branch $sourcebranch

Write-Host Get objects from $SetupParameters.baseBranch
$result = git.exe checkout --force $SetupParameters.baseBranch --quiet 

Write-Host Saving base branch...
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName 'Export-GITtoNAVNewSyntaxSource.ps1' -BuildSettings $BuildSettings
} else {    
    $buildSource = Join-Path $PSScriptRoot 'Export-GITtoNAVNewSyntaxSource.ps1'
    . $buildSource -Repository $Repository | Out-Null
}

Write-Host Switching back to Source Branch
$result = git.exe checkout --force $sourcebranch --quiet 

Write-Host Saving product branch...
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName 'Export-GITtoNAVNewSyntaxModified.ps1' -BuildSettings $BuildSettings
} else {
    $buildSource = Join-Path $PSScriptRoot 'Export-GITtoNAVNewSyntaxModified.ps1'
    . $buildSource -Repository $Repository | Out-Null
}

Write-Host Creating deltas in your work folder...
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName 'Create-Deltas.ps1' -BuildSettings $BuildSettings
} else {
    $buildSource = Join-Path $PSScriptRoot 'Create-Deltas.ps1'
    . $buildSource -Repository $Repository | Out-Null
}

Write-Host Creating reverse deltas in your work folder...
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName 'Create-ReverseDeltas.ps1' -BuildSettings $BuildSettings
} else {
    $buildSource = Join-Path $PSScriptRoot 'Create-ReverseDeltas.ps1'
    . $buildSource -Repository $Repository | Out-Null
}

$SourceFolder = (Join-Path $SetupParameters.workFolder 'Deltas')
$TargetFolder = $SetupParameters.NewSyntaxDeltasPath

if (Test-Path $TargetFolder) 
{
    Remove-Item -Path $TargetFolder -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -Path $TargetFolder -ItemType Directory | Out-Null
Write-Host Saving new deltas $TargetFileName
Copy-Item -Path (Join-Path $SourceFolder '*.*') -Destination $TargetFolder

$SourceFolder = (Join-Path $SetupParameters.workFolder 'ReverseDeltas')
$TargetFolder = $SetupParameters.NewSyntaxReverseDeltasPath 

if (Test-Path $TargetFolder) 
{
    Remove-Item -Path $TargetFolder -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -Path $TargetFolder -ItemType Directory | Out-Null
Write-Host Saving new reverse deltas $TargetFileName
Copy-Item -Path (Join-Path $SourceFolder '*.*') -Destination $TargetFolder
