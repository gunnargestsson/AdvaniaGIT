$SourceObjects = Join-Path $SetupParameters.DeltasPath '*.DELTA'
if (Test-Path $SourceObjects) {
    $DeltasFilePath = (Join-Path $SetupParameters.workFolder 'Deltas')
    Remove-Item -Path $DeltasFilePath -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -Path $DeltasFilePath -ItemType Directory -ErrorAction SilentlyContinue
    Copy-Item -Path $SourceObjects -Destination $DeltasFilePath-Force
    Write-Host "Deltas copied to the Work Folder"
} else {
    Write-Host -ForegroundColor Red "Deltas not found in repository!"
}
