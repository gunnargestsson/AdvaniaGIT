if ($SetupParameters.BuildMode) {    
    Get-ChildItem -Path (Join-Path $SetupParameters.repository 'Dependencies') -Filter "*Test*.app" | % {Remove-Item -Path $_.FullName}
}