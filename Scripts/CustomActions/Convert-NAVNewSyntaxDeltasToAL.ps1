if (Test-Path $SetupParameters.NewSyntaxDeltasPath) {
    $Txt2AlPath = Join-Path $SetupParameters.navIdePath "Txt2Al.exe"
    if (Test-Path $Txt2AlPath) {
        Remove-Item -Path $SetupParameters.VSCodePath -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -Path $SetupParameters.VSCodePath -ItemType Directory 
        . $Txt2AlPath --source="$($SetupParameters.NewSyntaxDeltasPath)" --target="$($SetupParameters.VSCodePath)" --Rename --extensionStartId="$($SetupParameters.uidOffset)"
    } else {
        Write-Host -ForegroundColor Red "Txt 2 AL conversion not supported in this version!"
    }
} else {
    Write-Host -ForegroundColor Red "New Syntax Delta folder must exits!"
}