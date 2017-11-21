# Florian Dietrich
function Get-GitModifiedFiles
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$GitCommitId
    )
    $changedFileList = @()
    try { 
        $changedFileList += git.exe diff --relative --name-only --diff-filter=ACMRTUXB $GitCommitId
        foreach ($changedFile in $changedFileList) {
            $FilePath = Join-Path (Get-Location).Path $changedFile
            $changedFileList += (Get-Item -Path $FilePath)
        }
    }
    catch {}
    return $changedFileList
}