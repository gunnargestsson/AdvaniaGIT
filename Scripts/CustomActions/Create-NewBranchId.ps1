if (Test-Path $SetupParameters.SetupPath) {
    $BranchSetup = Get-Content -Path $SetupParameters.SetupPath -Encoding UTF8 | Out-String | ConvertFrom-Json
    $BranchSetup.branchId = (New-Guid)
    Set-Content -Path $SetupParameters.SetupPath -Encoding UTF8 -Value (ConvertTo-Json -InputObject $BranchSetup)
}
