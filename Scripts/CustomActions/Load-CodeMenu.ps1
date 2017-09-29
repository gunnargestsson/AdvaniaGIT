Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings

do {
    Clear-Host
    Write-Host ""
    Write-Host "C/AL Code Menu for branch $($SetupParameters.navRelease) $($SetupParameters.Branchname)"
    Write-Host ""
    $input = Read-Host "Please select action (
        0 = return
        1 = GIT > NAV
        2 = NAV Modified > GIT
        3 = NAV > GIT  
        4 = GIT > Source.txt
        5 = GIT > Modified.txt
        6 = NAV > AllObjects.fob 
        7 = Add Target.txt to GIT
        8 = Replace GIT with Target.txt
        9 = Create Deltas in Work Folder (Source vs. Modified)
        10 = Create Code Deltas in Work Folder (Source vs. Modified)
        11 = Create Reverse Deltas in Work Folder (Modified vs. Source)
        12 = Build Deltas & Reverse Deltas in GIT
        13 = Merge Deltas in Work Folder with Source to create Target
        14 = Build Target from base branch and delta branches (including GIT Delta)
        15 = Build Source from base branch and delta branches (excluding GIT Delta)
        16 = Clear Comment Section from NAV Objects
        "
    $currentbranch = git.exe rev-parse --abbrev-ref HEAD
    if ($SetupParameters.Branchname -ne $currentbranch) {
        Write-Host -ForegroundColor Red "Menu is running on branch $($SetupParameters.Branchname) but you have switched to branch $currentbranch"
        $input = Read-Host "Press enter to continue..."
    } else {
        switch ($input) {
            '0' { exit }
            '1' { & (Join-Path $PSScriptRoot ImportFrom-GITtoNAV.ps1) }
            '2' { & (Join-Path $PSScriptRoot ImportFrom-ModifiedNAVtoGIT.ps1) }
            '3' { & (Join-Path $PSScriptRoot ImportFrom-NAVtoGIT.ps1) }            
            '4' { & (Join-Path $PSScriptRoot Export-GITtoSource.ps1) }
            '5' { & (Join-Path $PSScriptRoot Export-GITtoModified.ps1) }
            '6' { & (Join-Path $PSScriptRoot Export-NavFob.ps1) }
            '7' { & (Join-Path $PSScriptRoot ImportFrom-TargetToGIT.ps1) }
            '8' { & (Join-Path $PSScriptRoot Replace-GITwithTarget.ps1) }
            '9' { & (Join-Path $PSScriptRoot Create-Deltas.ps1) }
            '10' { & (Join-Path $PSScriptRoot Create-CodeDeltas.ps1) }
            '11' { & (Join-Path $PSScriptRoot Create-ReverseDeltas.ps1) }
            '12' { & (Join-Path $PSScriptRoot Build-DeltasInGIT.ps1) }
            '13' { & (Join-Path $PSScriptRoot Merge-Deltas.ps1) }
            '14' { & (Join-Path $PSScriptRoot Build-Target.ps1) }
            '15' { & (Join-Path $PSScriptRoot Build-Source.ps1) }
            '16' { & (Join-Path $PSScriptRoot Clear-NAVCommentSection.ps1) }            

        }   
        $input = Read-Host "Press enter to continue..."                 
    }
}
until ($input -ieq '0')        
