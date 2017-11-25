$ObjectFileName = (Join-Path $SetupParameters.workFolder 'Source.txt')    

if (Test-Path $ObjectFileName) {
    $SourceFolder = Join-Path $SetupParameters.Repository 'Source'
    New-Item -Path $SourceFolder -ItemType Directory -ErrorAction SilentlyContinue
    $SourceObjects = Join-Path $SetupParameters.buildSourcePath 'Source.txt'
    Copy-Item -Path $ObjectFileName -Destination $SourceObjects -Force
    Write-Host "Source.txt copied from the Work Folder"
} else {
    Write-Error -ForegroundColor Red "Source.txt not found in Work Folder!" -ErrorAction Stop    
}
