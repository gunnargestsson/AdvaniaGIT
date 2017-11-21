Function Remove-NAVObjectsProperties
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject[]]$ObjectList
        )
    Load-ModelTools -SetupParameters $SetupParameters
    $ObjectsPath = (Join-Path $SetupParameters.workFolder 'Objects')
    Remove-Item -Path $ObjectsPath -Recurse -ErrorAction SilentlyContinue
    New-Item -Path $ObjectsPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    foreach ($object in $ObjectList | Where-Object -Property DirectoryName -IEQ $SetupParameters.ObjectsPath) {
        Set-NAVApplicationObjectProperty -TargetPath $object.FullName -VersionListProperty '' -ModifiedProperty No -DateTimeProperty '' 
    }
    UnLoad-ModelTools
}
