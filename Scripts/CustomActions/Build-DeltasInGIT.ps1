Set-Location -Path $Repository

Check-GitNotUnattached
Check-GitCommitted

$sourcebranch = git.exe rev-parse --abbrev-ref HEAD 
Write-Host Save Source Branch $sourcebranch

Write-Host Get objects from $SetupParameters.baseBranch
$result = git.exe checkout --force $SetupParameters.baseBranch --quiet 

Write-Host Saving base branch...
$buildSource = Join-Path $PSScriptRoot 'Export-GITtoSource.ps1'
. $buildSource -Repository $Repository | Out-Null

Write-Host Switching back to Source Branch
$result = git.exe checkout --force $sourcebranch --quiet 

Write-Host Saving product branch...
$buildSource = Join-Path $PSScriptRoot 'Export-GITtoModified.ps1'
. $buildSource -Repository $Repository | Out-Null

Write-Host Creating deltas in your work folder...
$buildSource = Join-Path $PSScriptRoot 'Create-Deltas.ps1'
. $buildSource -Repository $Repository | Out-Null

Write-Host Creating reverse deltas in your work folder...
$buildSource = Join-Path $PSScriptRoot 'Create-ReverseDeltas.ps1'
. $buildSource -Repository $Repository | Out-Null

$SourceFolder = (Join-Path $SetupParameters.workFolder 'Deltas')
$TargetFolder = $SetupParameters.DeltasPath

if (Test-Path $TargetFolder) 
{
  Remove-Item -Path $TargetFolder -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -Path $TargetFolder -ItemType Directory | Out-Null
Write-Host Saving new deltas to $TargetFolder
Copy-Item -Path (Join-Path $SourceFolder '*.*') -Destination $TargetFolder

$SourceFolder = (Join-Path $SetupParameters.workFolder 'ReverseDeltas')
$TargetFolder = $SetupParameters.ReverseDeltasPath 

if (Test-Path $TargetFolder) 
{
  Remove-Item -Path $TargetFolder -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -Path $TargetFolder -ItemType Directory | Out-Null
Write-Host Saving new reverse deltas to $TargetFolder
Copy-Item -Path (Join-Path $SourceFolder '*.*') -Destination $TargetFolder


