function Check-GitCommitted
{
    try { $gitPath = (Where.exe /q git.exe)  } 
    catch {}
    if ($gitPath) {
        if (Test-Path $gitPath) {
            $gitstatus = git.exe status -s
            if ($gitstatus -gt '')
            {
                Write-Error "There are uncommited changes!!!" -ErrorAction Stop
            }
        }
    }
}