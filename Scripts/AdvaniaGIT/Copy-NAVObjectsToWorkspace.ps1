Function Copy-NAVObjectsToWorkspace
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject[]]$ObjectList,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$AllObjects
        )
    $ObjectsPath = (Join-Path $SetupParameters.workFolder 'Objects')
    Remove-Item -Path $ObjectsPath -Recurse -ErrorAction SilentlyContinue
    New-Item -Path $ObjectsPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    if ($AllObjects) {
        Copy-Item -Path (Join-Path $SetupParameters.ObjectsPath '*.txt') -Destination $ObjectsPath
    } else {
        foreach ($object in $ObjectList | Where-Object -Property DirectoryName -IEQ $SetupParameters.ObjectsPath) {
            Copy-Item -Path $object.FullName -Destination $ObjectsPath
        }
    }
}
