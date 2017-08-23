function Check-GitNotUnattached
{
    # Check for detatched branch
    try { $gitPath = (Where.exe /q git.exe)  } 
    catch {}
    if ($gitPath) {
        if (Test-Path $gitPath) {
            Set-Location -Path $Repository
            $GitBranchName = (git.exe rev-parse --abbrev-ref HEAD)
            if ($GitBranchName -eq 'HEAD')
            {
                Write-Error "Unattached commit forbidden !" -ErrorAction Stop
            }
        }
    }
}
