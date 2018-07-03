if ($BranchSettings.dockerContainerId -gt "") { $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings }

if (Test-Path $SetupParameters.NewSyntaxDeltasPath) {
    $Txt2AlPath = Join-Path $SetupParameters.navIdePath "Txt2Al.exe"
    if (Test-Path $Txt2AlPath) {
        New-Item -Path $SetupParameters.VSCodePath -ItemType Directory -ErrorAction SilentlyContinue
        . $Txt2AlPath --source="$($SetupParameters.NewSyntaxDeltasPath)" --target="$($SetupParameters.VSCodePath)" --Rename --extensionStartId="$($SetupParameters.uidOffset)"
    } else {
        Write-Host -ForegroundColor Red "Txt 2 AL conversion not supported in this version!"
    }
} else {
    Write-Host -ForegroundColor Red "New Syntax Delta folder must exits!"
}    
