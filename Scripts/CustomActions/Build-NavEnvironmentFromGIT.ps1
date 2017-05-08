# Build NAV Environment
& (Join-path $PSScriptRoot 'Build-NavEnvironment.ps1')
# Update from Git
& (Join-path $PSScriptRoot 'ImportFrom-GITtoNAV.ps1')
