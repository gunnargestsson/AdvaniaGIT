if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
    if (Test-Path -Path (Join-Path $SetupParameters.repository 'Artifacts')) {
        Remove-Item -Path (Join-Path $SetupParameters.repository 'Artifacts') -Recurse -Force
    }
    New-Item -Path (Join-Path $SetupParameters.repository 'Artifacts') -ItemType Directory -Force | Out-Null 
    Copy-Item -Path (Join-Path $BranchWorkFolder 'Symbols\*.*') -Destination (Join-Path $Repository 'Artifacts') -Force
    foreach ($artifact in (Get-ChildItem -Path (Join-Path $Repository 'Artifacts') -Filter "*.app")) {
        $newName = (Join-Path $artifact.Directory "$($SetupParameters.projectName)-$($artifact.Name)")
        Rename-Item -Path $artifact.FullName -NewName $newName
    }
}    
