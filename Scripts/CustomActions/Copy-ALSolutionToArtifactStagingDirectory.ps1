if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
    Remove-Item -Path (Join-Path $SetupParameters.repository 'Artifacts') -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -Path (Join-Path $SetupParameters.repository 'Artifacts') -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null 
    Copy-Item -Path (Join-Path $BranchWorkFolder 'out\*.*') -Destination (Join-Path $Repository 'Artifacts')
}    
