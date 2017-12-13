if (![String]::IsNullOrEmpty($SetupParameters.SourceFilePath) -and ![String]::IsNullOrEmpty($SetupParameters.DestinationFilePath)) {
    $SourceFile = Get-Item -Path $SetupParameters.SourceFilePath 
    if ($SourceFile) {
        Write-Host "Moving ${SourceFile} to $($SetupParameters.DestinationFilePath)..."
        Move-Item -Path $SourceFile.FullName -Destination $SetupParameters.DestinationFilePath -Force -ErrorAction SilentlyContinue
    }
}