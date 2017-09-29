Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings

do {
    Clear-Host
    Write-Host ""
    Write-Host "Extension v1 Menu for branch $($SetupParameters.navRelease) $($SetupParameters.Branchname)"
    Write-Host ""
    $input = Read-Host "Please select action :
        0 = return
        1 = Create Extension in GIT
        2 = Publish Extension to Default Server Instance
        3 = Unpublish Extension from Default Server Instance
        4 = Base Branch Server Instance - Publish Extension 
        5 = Base Branch Server Instance - Unpublish Extension
        6 = Export NAV Permission Sets to GIT
        "
    $currentbranch = git.exe rev-parse --abbrev-ref HEAD
    if ($SetupParameters.Branchname -ne $currentbranch) {
        Write-Host -ForegroundColor Red "Menu is running on branch $($SetupParameters.Branchname) but you have switched to branch $currentbranch"
        $input = Read-Host "Press enter to continue..."
    } else {
        switch ($input) {
            '0' { 
                    $input = "q"
                    break 
                }
            '1' { & (Join-Path $PSScriptRoot Create-Extension.ps1) }
            '2' { & (Join-Path $PSScriptRoot Publish-Extension.ps1) }
            '3' { & (Join-Path $PSScriptRoot Unpublish-Extension.ps1) }
            '4' { & (Join-Path $PSScriptRoot Publish-ExtensionToBaseBranch.ps1) }
            '5' { & (Join-Path $PSScriptRoot Unpublish-ExtensionFromBaseBranch.ps1) }
            '6' { & (Join-Path $PSScriptRoot Export-PermissionSets.ps1) }
        }                    
    }
}
until ($input -ieq '0')        
