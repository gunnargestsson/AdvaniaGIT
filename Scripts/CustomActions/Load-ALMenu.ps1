Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings

do {
    Clear-Host
    Write-Host ""
    Write-Host "AL Conversion Menu Menu for branch $($SetupParameters.navRelease) $($SetupParameters.Branchname)"
    Write-Host ""
    $input = Read-Host "Please select action :
        0 = return
        1 = Export NAV New Syntax to GIT
        2 = Build New Syntax Deltas & Reverse Deltas in GIT
        3 = Convert New Syntax Deltas to AL
        4 = Open VS Code with current branch as master 
        5 = Open VS Code with base branch as master
        "
    $currentbranch = git.exe rev-parse --abbrev-ref HEAD
    if ($SetupParameters.Branchname -ne $currentbranch) {
        Write-Host -ForegroundColor Red "Menu is running on branch $($SetupParameters.Branchname) but you have switched to branch $currentbranch"
        $input = Read-Host "Press enter to continue..."
    } else {
        switch ($input) {
            '0' { exit }
            '1' { & (Join-Path $PSScriptRoot ImportFrom-NAVNewSyntaxToGIT.ps1) }
            '2' { & (Join-Path $PSScriptRoot Build-NAVNewSyntaxDeltasInGIT.ps1) }
            '3' { & (Join-Path $PSScriptRoot Convert-NAVNewSyntaxDeltasToAL.ps1) }
            '4' { & (Join-Path $PSScriptRoot Start-VSCodeOnCurrentBranch.ps1) }
            '5' { & (Join-Path $PSScriptRoot Start-VSCodeOnBaseBranch.ps1) }
        } 
        $anyKey = Read-Host -Prompt "Press enter to continue..."                   
    }
}
until ($input -ieq '0')        
