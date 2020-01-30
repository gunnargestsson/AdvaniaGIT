$currentbranch = git.exe rev-parse --abbrev-ref HEAD
if ($currentbranch -ne "master") {
    Write-Error "Will only work on master branch!";
    throw
}
$gitstatus = git.exe status -s
if ($gitstatus -gt '')
{
    Write-Error "There are uncommited changes!!!" -ErrorAction Stop
    throw
}

Write-Host "Fetch branches from GIT server..."
git.exe fetch --prune

Write-Host "Remove all local branches except master..."
git branch | Where-Object -FilterScript {$_ -ne "* master"} | % {git branch $_.trim() -d} 