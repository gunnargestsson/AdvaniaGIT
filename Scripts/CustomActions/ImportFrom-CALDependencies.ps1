$CALObjectsPath = Join-Path $SetupParameters.repository 'CAL'
if (Test-Path $CALObjectsPath) {
    Write-Host "Enabling server instance symbol reference update..."
    & (Join-path $PSScriptRoot 'Start-ALSymbolReferenceGenerationOnServer.ps1')

    # Import CAL objects required for symbols
    & (Join-path $PSScriptRoot 'ImportFrom-GITCALObjectsToNAV.ps1')

    # Compile Queries to fix symbols
    & (Join-path $PSScriptRoot 'Start-CompileQueriesOnHost.ps1')
    & (Join-path $PSScriptRoot 'Start-CompileXMLPortOnHost.ps1')
    & (Join-path $PSScriptRoot 'Start-CompileModifiedObjectsOnHost.ps1')
}