$VSCodePaths = @((Join-Path $env:ProgramFiles "Microsoft VS Code\Code.exe"); (Join-Path ${env:ProgramFiles(x86)} "Microsoft VS Code\Code.exe"))
foreach ($VSCodePath in $VSCodePaths) {
    if (Test-Path $VSCodePath) {
        New-NAVAppJson -SetupParameters $SetupParameters       
        Start-Process -FilePath $VSCodePath -ArgumentList "--add $($SetupParameters.VSCodePath)"
    }
}

