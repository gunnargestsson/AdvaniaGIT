Function Copy-NAVObjectsToWorkspace
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject[]]$ObjectList
        )
    $ObjectsPath = (Join-Path $SetupParameters.workFolder 'Objects')
    Remove-Item -Path $ObjectsPath -Recurse -ErrorAction SilentlyContinue
    New-Item -Path $ObjectsPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    foreach ($object in $ObjectList | Where-Object -Property DirectoryName -IEQ $SetupParameters.ObjectsPath) {
        Copy-Item -Path $object.FullName -Destination $ObjectsPath
    }
}
