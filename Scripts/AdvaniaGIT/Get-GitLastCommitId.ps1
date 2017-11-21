# Florian Dietrich
function Get-GitLastCommitId
{
    try {
        $gitCommitId = git.exe rev-parse HEAD
        return $gitCommitId
    } catch {}
}