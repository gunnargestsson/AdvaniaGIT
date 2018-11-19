if (!(Test-Path $SetupParameters.VSCodePath)) {
    New-Item -Path $SetupParameters.VSCodePath -ItemType Directory
}


if (!(Test-Path $SetupParameters.VSCodeTestPath)) {
    New-Item -Path $SetupParameters.VSCodeTestPath -ItemType Directory
}

$VSCodePaths = @((Join-Path $env:ProgramFiles "Microsoft VS Code\Code.exe"); (Join-Path ${env:ProgramFiles(x86)} "Microsoft VS Code\Code.exe"))
foreach ($VSCodePath in $VSCodePaths) {
    if (Test-Path $VSCodePath) {
        Start-Process -FilePath $VSCodePath -ArgumentList "--add $($SetupParameters.VSCodePath) $($SetupParameters.VSCodeTestPath)"
    }
}

