if (Test-Path $SetupParameters.SetupPath) {
    $BranchSetup = Get-Content -Path $SetupParameters.SetupPath -Encoding UTF8 | Out-String | ConvertFrom-Json
    $BranchSetup.branchId = (New-Guid)
    if ([bool]($BranchSetup.PSObject.Properties.name -match "dockerShared")) {
        $BranchSetup.dockerShared = ""    
    }
    Set-Content -Path $SetupParameters.SetupPath -Encoding UTF8 -Value (ConvertTo-Json -InputObject $BranchSetup)
}
