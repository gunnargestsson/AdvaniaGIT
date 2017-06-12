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
        $BaseObjectsFile = Get-NAVSourceFilePath -SetupParameters $SetupParameters
        Test-Path $BaseObjectsFile -ErrorAction Stop | Out-Null
        $DeltaFolder = Join-Path $SetupParameters.workFolder $SetupParameters.deltasPath
        $ReverseDeltaFolder = Join-Path $SetupParameters.workFolder $SetupParameters.reverseDeltasPath
        $DeltasPath = Join-Path $SetupParameters.Repository $SetupParameters.deltasPath
        $ReverseDeltasPath = Join-Path $SetupParameters.Repository $SetupParameters.reverseDeltasPath

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
