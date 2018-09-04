if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.WorkFolder $SetupParameters.branchId
    New-Item -Path (Join-Path $SetupParameters.repository 'Artifacts') -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null 
    Copy-Item -Path (Join-Path $BranchWorkFolder 'Symbols\*.*') -Destination (Join-Path $Repository 'Artifacts')
}    
