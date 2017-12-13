if (![String]::IsNullOrEmpty($SetupParameters.SourceFilePath) -and ![String]::IsNullOrEmpty($SetupParameters.DestinationFilePath)) {
    $SourceFile = Get-Item -Path $SetupParameters.SourceFilePath
    Move-Item -Path $SourceFile.FullName -Destination $SetupParameters.DestinationFilePath -Force
}