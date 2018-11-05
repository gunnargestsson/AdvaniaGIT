if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
    Copy-Item -Path (Join-Path $BranchWorkFolder 'out\*.*') -Destination (Join-Path $BranchWorkFolder 'Symbols')
}    
