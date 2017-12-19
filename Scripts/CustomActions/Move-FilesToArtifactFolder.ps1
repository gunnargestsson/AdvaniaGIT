if (![String]::IsNullOrEmpty($SetupParameters.DestinationFilePath)) {
    New-Item -Path $SetupParameters.DestinationFilePath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

    # Backup Folder
    $backups = Get-ChildItem -Path $SetupParameters.backupPath -Filter "$($SetupParameters.navRelease)-$($SetupParameters.projectName).*"
    foreach ($file in $backups) {
        Write-Host "Moving $($file.Name) to $($SetupParameters.DestinationFilePath)..."       
        Move-Item -Path $file.FullName -Destination $SetupParameters.DestinationFilePath -Force -ErrorAction SilentlyContinue
    }

    # Workspace Folder
    $results = Get-ChildItem -Path $SetupParameters.WorkFolder -Filter "$($SetupParameters.navRelease)-$($SetupParameters.projectName).*"
    foreach ($file in $results) {
        Write-Host "Moving $($file.Name) to $($SetupParameters.DestinationFilePath)..."       
        Move-Item -Path $file.FullName -Destination $SetupParameters.DestinationFilePath -Force -ErrorAction SilentlyContinue
    }
}