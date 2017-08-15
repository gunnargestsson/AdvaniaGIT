function Split-Solution
{
    [CmdletBinding()]
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$ObjectsFilePath
    )
    if ($SetupParameters.storeAllObjects -eq "false" -or $SetupParameters.storeAllObjects -eq $false) {
        $SourceFilePath = Get-NAVSourceFilePath -SetupParameters $SetupParameters
        $BaseObjectsFile = (Join-Path $SetupParameters.WorkFolder "Source.txt")
        Copy-Item -Path $SourceFilePath -Destination $BaseObjectsFile -Force
        if ($SetupParameters.objectProperties -eq "false") {
            Write-Host "Clearing object properties..."
            Set-NAVApplicationObjectProperty -TargetPath $BaseObjectsFile -VersionListProperty '' -DateTimeProperty '' -ModifiedProperty No
        }
        Test-Path $BaseObjectsFile -ErrorAction Stop | Out-Null
        $DeltaFolder = Join-Path $SetupParameters.workFolder 'Deltas'
        $ReverseDeltaFolder = Join-Path $SetupParameters.workFolder 'ReverseDeltas'
        $DeltasPath = $SetupParameters.deltasPath
        $ReverseDeltasPath = $SetupParameters.reverseDeltasPath

        Write-Host "Comparing Base Objects and Exported Objects..."
        Remove-Item -Path $DeltaFolder -Recurse -ErrorAction SilentlyContinue
        New-Item -Path $DeltaFolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        Compare-NAVApplicationObject -Original $BaseObjectsFile -Modified $ObjectsFilePath -Delta $DeltaFolder | Where-Object CompareResult -eq 'Identical' | foreach {  Remove-Item (Join-Path $DeltaFolder ($_.ObjectType.substring(0,3) + $_.Id + '.delta')) }
        Remove-Item -Path $DeltasPath -Recurse -ErrorAction SilentlyContinue
        New-Item -Path $DeltasPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        Copy-Item -Path (Join-Path $DeltaFolder '*.*') -Destination $DeltasPath
        Write-Host "Deltas created."

        Remove-Item -Path $ReverseDeltaFolder -Recurse -ErrorAction SilentlyContinue
        New-Item -Path $ReverseDeltaFolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        Compare-NAVApplicationObject -Original $ObjectsFilePath -Modified $BaseObjectsFile -Delta $ReverseDeltaFolder | Where-Object CompareResult -eq 'Identical' | foreach {  Remove-Item (Join-Path $ReverseDeltaFolder ($_.ObjectType.substring(0,3) + $_.Id + '.delta')) }
        Remove-Item -Path $ReverseDeltasPath -Recurse -ErrorAction SilentlyContinue
        New-Item -Path $ReverseDeltasPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        Copy-Item -Path (Join-Path $ReverseDeltaFolder '*.*') -Destination $ReverseDeltasPath
        Write-Host "Reverse Deltas created."
    }
}
