Check-GitCommitted 
if ([bool]($SetupParameters.PSObject.Properties.name -match "newBranch")) {
    $parentbranch = git.exe rev-parse --abbrev-ref HEAD
    git.exe checkout -q -b $SetupParameters.newBranch
    $BranchSetup = Get-Content -Path $SetupParameters.SetupPath -Encoding UTF8 | Out-String | ConvertFrom-Json
    $BranchSetup.branchId = New-Guid
    if (![bool]($BranchSetup.PSObject.Properties.name -match "baseBranch")) {
        $BranchSetup | Add-Member -MemberType NoteProperty -Name baseBranch -Value ""
    }
    $BranchSetup.baseBranch = $parentbranch
    if (![bool]($BranchSetup.PSObject.Properties.name -match "projectName")) {
        $BranchSetup | Add-Member -MemberType NoteProperty -Name projectName -Value ""
    }
    $BranchSetup.projectName = $SetupParameters.newBranch
    Set-Content -Path $SetupParameters.SetupPath -Encoding UTF8 -Value (ConvertTo-Json -InputObject $BranchSetup)     
}