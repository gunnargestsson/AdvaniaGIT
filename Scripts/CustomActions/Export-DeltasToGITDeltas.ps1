$DeltasFilePath = (Join-Path $SetupParameters.workFolder 'Deltas')
if (Test-Path $DeltasFilePath) {
    $SourceFolder = Join-Path $SetupParameters.DeltasPath
    New-Item -Path $SourceFolder -ItemType Directory -ErrorAction SilentlyContinue
    $SourceObjects = Join-Path $DeltasFilePath '*.DELTA'
    Copy-Item -Path $SourceObjects -Destination $DeltasFilePath -Force
    Write-Host "Deltas copied from the Work Folder"
} else {
    Write-Host -ForegroundColor Red "Deltas not found in Work Folder!"
}

    