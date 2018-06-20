if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.WorkFolder $SetupParameters.branchId    
    Copy-Item -Path (Join-Path $BranchWorkFolder 'out\*.*') -Destination (Join-Path $BranchWorkFolder 'Symbols')
}    
