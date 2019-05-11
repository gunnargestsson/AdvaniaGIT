if ([String]::IsNullOrEmpty($SetupParameters.DestinationFilePath)) {
    $ArtifactsPath = Join-Path $SetupParameters.repository 'Artifacts'
} else {
    $ArtifactsPath = $SetupParameters.DestinationFilePath
}

New-Item -Path $SArtifactsPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

# Backup Folder
$backups = Get-ChildItem -Path $SetupParameters.backupPath -Filter "$($SetupParameters.navRelease)-$($SetupParameters.projectName).*"
foreach ($file in $backups) {
    Write-Host "Moving $($file.Name) to $($ArtifactsPath)..."       
    Move-Item -Path $file.FullName -Destination $ArtifactsPath -Force -ErrorAction SilentlyContinue
}

# Workspace Folder
$results = Get-ChildItem -Path $SetupParameters.WorkFolder -Filter "$($SetupParameters.navRelease)-$($SetupParameters.projectName).*"
foreach ($file in $results) {
    Write-Host "Moving $($file.Name) to $($ArtifactsPath)..."       
    Move-Item -Path $file.FullName -Destination $ArtifactsPath -Force -ErrorAction SilentlyContinue
}
