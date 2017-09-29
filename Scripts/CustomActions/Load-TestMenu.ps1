Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings

do {
    Clear-Host
    Write-Host ""
    Write-Host "Test Menu for branch $($SetupParameters.navRelease) $($SetupParameters.Branchname)"
    Write-Host ""
    $input = Read-Host "Please select action :
        0 = return
        1 = Run All Automated Tests
        2 = Run Failed Tests Only
        3 = Run Tests on Modified Objects 
        4 = Show Automated Test Results
        "
    $currentbranch = git.exe rev-parse --abbrev-ref HEAD
    if ($SetupParameters.Branchname -ne $currentbranch) {
        Write-Host -ForegroundColor Red "Menu is running on branch $($SetupParameters.Branchname) but you have switched to branch $currentbranch"
        $input = Read-Host "Press enter to continue..."
    } else {
        switch ($input) {
            '0' { exit }
            '1' { & (Join-Path $PSScriptRoot Start-FullTest.ps1) }
            '2' { & (Join-Path $PSScriptRoot Restart-FailedTest.ps1) }
            '3' { & (Join-Path $PSScriptRoot Start-ModifiedObjectsTest.ps1) }
            '4' { & (Join-Path $PSScriptRoot Save-TestResultsCsv.ps1) }

        }                    
        $input = Read-Host "Press enter to continue..."
    }
}
until ($input -ieq '0')        
