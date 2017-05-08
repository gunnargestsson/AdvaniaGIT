function Check-GitCommitted
{
    $gitstatus = git.exe status -s
    if ($gitstatus -gt '')
    {
        Write-Error "There are uncommited changes!!!" -ErrorAction Stop
    }
}