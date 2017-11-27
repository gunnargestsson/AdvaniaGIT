$sourceFilePath = Join-Path $SetupParameters.workFolder 'Source.txt'
Remove-Item -Path $sourceFilePath -Force -ErrorAction SilentlyContinue

Write-Host Saving GIT Build source to work folder...
$buildSource = Join-Path $PSScriptRoot 'Export-GITSourceToSource.ps1'
. $buildSource 

if (Test-Path $sourceFilePath) {
    Write-Host Saving product branch...
    $buildSource = Join-Path $PSScriptRoot 'Export-GITtoModified.ps1'
    . $buildSource |  Out-Null

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
    Write-Host Saving new deltas $TargetFileName
    Copy-Item -Path (Join-Path $SourceFolder '*.*') -Destination $TargetFolder

    $SourceFolder = (Join-Path $SetupParameters.workFolder 'ReverseDeltas')
    $TargetFolder = $SetupParameters.ReverseDeltasPath 

    if (Test-Path $TargetFolder) 
    {
      Remove-Item -Path $TargetFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -Path $TargetFolder -ItemType Directory | Out-Null
    Write-Host Saving new reverse deltas $TargetFileName
    Copy-Item -Path (Join-Path $SourceFolder '*.*') -Destination $TargetFolder
} 
