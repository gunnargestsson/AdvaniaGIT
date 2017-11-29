
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
        6 = GIT build source > Source.txt
        7 = Source.txt > GIT build source
        8 = NAV > AllObjects.fob 
        9 = Add Target.txt to GIT
        10 = Replace GIT with Target.txt
        11 = Create Deltas in Work Folder (Source vs. Modified)
        12 = Create Code Deltas in Work Folder (Source vs. Modified)
        13 = Create Reverse Deltas in Work Folder (Modified vs. Source)
        14 = Build Deltas & Reverse Deltas in GIT from base branch
        15 = Build Deltas & Reverse Deltas in GIT from last build source
        16 = Merge Deltas in Work Folder with Source to create Target
        17 = Build Target from base branch and delta branches (including GIT Delta)
        18 = Build Source from base branch and delta branches (excluding GIT Delta)
        19 = Clear Comment Section from NAV Objects
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
            '6' { & (Join-Path $PSScriptRoot Export-GITSourceToSource.ps1) }
            '7' { & (Join-Path $PSScriptRoot Export-SourceToGITSource.ps1) }
            '8' { & (Join-Path $PSScriptRoot Export-NavFob.ps1) }
            '9' { & (Join-Path $PSScriptRoot ImportFrom-TargetToGIT.ps1) }
            '10' { & (Join-Path $PSScriptRoot Replace-GITwithTarget.ps1) }
            '11' { & (Join-Path $PSScriptRoot Create-Deltas.ps1) }
            '12' { & (Join-Path $PSScriptRoot Create-CodeDeltas.ps1) }
            '13' { & (Join-Path $PSScriptRoot Create-ReverseDeltas.ps1) }
            '14' { & (Join-Path $PSScriptRoot Build-DeltasInGIT.ps1) }
            '15' { & (Join-Path $PSScriptRoot Build-DeltasFromSourceInGIT.ps1) }
            '16' { & (Join-Path $PSScriptRoot Merge-Deltas.ps1) }
            '17' { & (Join-Path $PSScriptRoot Build-Target.ps1) }
            '18' { & (Join-Path $PSScriptRoot Build-Source.ps1) }
            '19' { & (Join-Path $PSScriptRoot Clear-NAVCommentSection.ps1) }            

        }   
        $input = Read-Host "Press enter to continue..."                 
    }
}
until ($input -ieq '0')        
