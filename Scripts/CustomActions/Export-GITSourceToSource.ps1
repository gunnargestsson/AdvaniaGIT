$SourceObjects = Join-Path $SetupParameters.Repository 'Source\Source.txt'
if (Test-Path $SourceObjects) {
    $ObjectFileName = (Join-Path $SetupParameters.workFolder 'Source.txt')
    Copy-Item -Path $SourceObjects -Destination $ObjectFileName -Force
    Write-Host "Source.txt copied to the Work Folder"
} else {
    Write-Host -ForegroundColor Red "Source.txt not found in repository!"
}
