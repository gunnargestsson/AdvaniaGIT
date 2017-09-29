Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings

do {
    Clear-Host
    Write-Host ""
    Write-Host "Client & Development Menu for branch $($SetupParameters.navRelease) $($SetupParameters.Branchname)"
    Write-Host ""
    $input = Read-Host "Please select action :
        0 = return
        1 = Start FinSql
        2 = Start Client
        3 = Start Web Client
        4 = Start VS Code 
        5 = Start Debugger
        7 = Base Branch - Start Client
        8 = Base Branch - Start Web Client
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
            '1' { & (Join-Path $PSScriptRoot Start-FinSql.ps1) }
            '2' { & (Join-Path $PSScriptRoot Start-Client.ps1) }
            '3' { & (Join-Path $PSScriptRoot Start-WebClient.ps1) }
            '4' { & (Join-Path $PSScriptRoot Start-VSCode.ps1) }
            '5' { & (Join-Path $PSScriptRoot Start-Debugger.ps1) }
            '6' { 
                    & (Join-Path $PSScriptRoot Start-Compile.ps1) 
                    $input = Read-Host "Press enter to continue..."
                }
            '7' { & (Join-Path $PSScriptRoot Start-BaseBranchClient.ps1) }
            '8' { & (Join-Path $PSScriptRoot Start-BaseBranchWebClient.ps1) }

        }                    
    }
}
until ($input -ieq '0')        
