if (![String]::IsNullOrEmpty($SetupParameters.SourceFilePath) -and ![String]::IsNullOrEmpty($SetupParameters.DestinationFilePath)) {
    $SourceFile = Get-Item -Path $SetupParameters.SourceFilePath 
    if ($SourceFile) {
        Write-Host "Moving ${SourceFile} to $($SetupParameters.DestinationFilePath)..."
        New-Item -Path $SetupParameters.DestinationFilePath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        Move-Item -Path $SourceFile.FullName -Destination $SetupParameters.DestinationFilePath -Force -ErrorAction SilentlyContinue
    }
}