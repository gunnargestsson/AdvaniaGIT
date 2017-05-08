function Check-GitNotUnattached
{
    # Check for detatched branch
    Set-Location -Path $Repository
    $GitBranchName = (git.exe rev-parse --abbrev-ref HEAD)
    if ($GitBranchName -eq 'HEAD')
    {
        Write-Error "Unattached commit forbidden !" -ErrorAction Stop
    }
}