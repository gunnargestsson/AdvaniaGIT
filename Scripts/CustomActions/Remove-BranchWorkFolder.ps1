if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.WorkFolder $SetupParameters.branchId
    Remove-Item -Path $BranchWorkFolder -Recurse -Force -ErrorAction SilentlyContinue
}    
