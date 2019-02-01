if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
    New-Item -Path $BranchWorkFolder -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item -Path (Join-Path $BranchWorkFolder 'out') -Force -Recurse -ErrorAction SilentlyContinue
    New-Item -Path (Join-Path $BranchWorkFolder 'out') -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
}

